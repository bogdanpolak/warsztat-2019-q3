unit Commnd.Import;

interface

uses
  System.RegularExpressions,
  Data.DB,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Variants,
  Vcl.Pattern.Command,
  Vcl.ExtCtrls,
  Vcl.DBGrids,
  Vcl.Controls,
  Vcl.Forms,
  ChromeTabs, ChromeTabsClasses, ChromeTabsTypes,
  // ---
  Frame.Import,
  ClientAPI.Books,
  ClientAPI.Readers,
  Consts.Application,
  ExtGUI.ListBox.Books,
  Data.Main;

type
  TImportCommand = class(TCommand)
  const
    Client_API_Token = '20be805d-9cea27e2-a588efc5-1fceb84d-9fb4b67c';
  private
    FFConfigBooks: TBooksListBoxConfigurator;
    FpnMain: TPanel;
    FChromeTabs1: TChromeTabs;
    FDataModMain: TDataModMain;
  protected
    procedure Guard; override;
  public
    class function BooksToDateTime(const s: string): TDateTime; static;
    class procedure ValidateReadersReport(jsRow: TJSONObject; email: string;
      var dtReported: TDateTime); static;
    procedure Execute; override;
    // ---
    property FBooksConfig: TBooksListBoxConfigurator read FFConfigBooks
      write FFConfigBooks;
    property MainFormFramePanel: TPanel read FpnMain write FpnMain;
    property MainFormChromeTabs: TChromeTabs read FChromeTabs1
      write FChromeTabs1;
    property MainDataModule: TDataModMain read FDataModMain write FDataModMain;
  end;

implementation

uses
  Helper.TApplication,
  Helper.TDBGrid,
  Helper.TJSONObject;

procedure TImportCommand.Guard;
begin
  inherited;
  Assert(FBooksConfig <> nil);
  Assert(MainDataModule <> nil);
end;

class function TImportCommand.BooksToDateTime(const s: string): TDateTime;
const
  months: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
  m: string;
  y: string;
  i: Integer;
  mm: Integer;
  yy: Integer;
begin
  m := s.Substring(0, 3);
  y := s.Substring(4);
  mm := 0;
  for i := 1 to 12 do
    if months[i].ToUpper = m.ToUpper then
      mm := i;
  if mm = 0 then
    raise ERangeError.Create('Incorect mont name in the date: ' + s);
  yy := y.ToInteger();
  Result := EncodeDate(yy, mm, 1);
end;

// TODO 3: Move this procedure into class (idea)
class procedure TImportCommand.ValidateReadersReport(jsRow: TJSONObject;
  email: string; var dtReported: TDateTime);

  function CheckEmail(const s: string): Boolean;
  const
    EMAIL_REGEX = '^((?>[a-zA-Z\d!#$%&''*+\-/=?^_`{|}~]+\x20*|"((?=[\x01-\x7f])'
      + '[^"\\]|\\[\x01-\x7f])*"\x20*)*(?<angle><))?((?!\.)' +
      '(?>\.?[a-zA-Z\d!#$%&''*+\-/=?^_`{|}~]+)+|"((?=[\x01-\x7f])' +
      '[^"\\]|\\[\x01-\x7f])*")@(((?!-)[a-zA-Z\d\-]+(?<!-)\.)+[a-zA-Z]' +
      '{2,}|\[(((?(?<!\[)\.)(25[0-5]|2[0-4]\d|[01]?\d?\d))' +
      '{4}|[a-zA-Z\d\-]*[a-zA-Z\d]:((?=[\x01-\x7f])[^\\\[\]]|\\' +
      '[\x01-\x7f])+)\])(?(angle)>)$';
  begin
    Result := System.RegularExpressions.TRegEx.IsMatch(s, EMAIL_REGEX);
  end;

begin
  if not CheckEmail(email) then
    raise Exception.Create('Invalid email addres');
  if not jsRow.IsValidIsoDateUtc('created', dtReported) then
    raise Exception.Create('Invalid date. Expected ISO format');
end;

procedure TImportCommand.Execute;
var
  frm: TFrameImport;
  tab: TChromeTab;
  jsData: TJSONArray;
  DBGrid1: TDBGrid;
  DataSrc1: TDataSource;
  DBGrid2: TDBGrid;
  DataSrc2: TDataSource;
  i: Integer;
  jsRow: TJSONObject;
  email: string;
  firstName: string;
  lastName: string;
  company: string;
  bookISBN: string;
  bookTitle: string;
  rating: Integer;
  oppinion: string;
  ss: array of string;
  dtReported: TDateTime;
  readerId: Variant;
  b: TBook;
  jsBooks: TJSONArray;
  jsBook: TJSONObject;
  TextBookReleseDate: string;
  b2: TBook;
begin
  inherited;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Import new Books data from OpenAPI
  //
  { TODO 2: [A] Extract method. Read comments and use meaningful name }
  jsBooks := ImportBooksFromWebService(Client_API_Token);
  try
    for i := 0 to jsBooks.Count - 1 do
    begin
      jsBook := jsBooks.Items[i] as TJSONObject;
      b := TBook.Create;
      b.status := jsBook.Values['status'].Value;
      b.title := jsBook.Values['title'].Value;
      b.isbn := jsBook.Values['isbn'].Value;
      b.author := jsBook.Values['author'].Value;
      TextBookReleseDate := jsBook.Values['date'].Value;
      b.releseDate := BooksToDateTime(TextBookReleseDate);
      b.pages := (jsBook.Values['pages'] as TJSONNumber).AsInt;
      b.price := StrToCurr(jsBook.Values['price'].Value);
      b.currency := jsBook.Values['currency'].Value;
      b.description := jsBook.Values['description'].Value;
      b.imported := Now();
      b2 := FBooksConfig.GetBookList(blkAll).FindByISBN(b.isbn);
      if not Assigned(b2) then
      begin
        FBooksConfig.InsertNewBook(b);
        // ----------------------------------------------------------------
        // Append report into the database:
        // Fields: ISBN, Title, Authors, Status, ReleseDate, Pages, Price,
        // Currency, Imported, Description
        MainDataModule.mtabBooks.InsertRecord([b.isbn, b.title, b.author,
          b.status, b.releseDate, b.pages, b.price, b.currency, b.imported,
          b.description]);
      end;
    end;
  finally
    jsBooks.Free;
  end;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Create new frame, show it add to ChromeTabs
  // 1. Create TFrameImport.
  // 2. Embed frame in pnMain (show)
  // 3. Add new ChromeTab
  //
  { TODO 2: [B] Extract method. Read comments and use meaningful }
  // Look for ChromeTabs1.Tabs.Add for code duplication
  if Assigned(MainFormFramePanel) and Assigned(MainFormChromeTabs) then
  begin
    frm := TFrameImport.Create(MainFormFramePanel);
    frm.Parent := MainFormFramePanel;
    frm.Visible := True;
    frm.Align := Vcl.Controls.alClient;
    tab := MainFormChromeTabs.Tabs.Add;
    tab.Caption := 'Readers';
    tab.Data := frm;
  end;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Dynamically Add TDBGrid to TFrameImport
  //
  { TODO 2: [C] Move code down separate bussines logic from GUI }
  // warning for dataset dependencies, discuss TDBGrid dependencies
  if Assigned(MainFormFramePanel) and Assigned(MainFormChromeTabs) then
  begin
    DataSrc1 := TDataSource.Create(frm);
    DBGrid1 := TDBGrid.Create(frm);
    DBGrid1.AlignWithMargins := True;
    DBGrid1.Parent := frm;
    DBGrid1.Align := Vcl.Controls.alClient;
    DBGrid1.DataSource := DataSrc1;
    DataSrc1.DataSet := MainDataModule.mtabReaders;
    DBGrid1.AutoSizeColumns();
  end;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Import new Reader Reports data from OpenAPI
  // - Load JSON from WebService
  // - Validate JSON and insert new a Readers into the Database
  //
  jsData := ImportReaderReportsFromWebService(Client_API_Token);
  { TODO 2: [D] Extract method. Block try-catch is separate responsibility }
  try
    for i := 0 to jsData.Count - 1 do
    begin
      { TODO 3: [A] Extract Reader Report code into the record TReaderReport (model layer) }
      { TODO 2: [F] Repeated code. Violation of the DRY rule }
      // Use TJSONObject helper Values return Variant.Null
      // ----------------------------------------------------------------
      //
      // Read JSON object
      //
      { TODO 3: [A] Move this code into record TReaderReport.LoadFromJSON }
      jsRow := jsData.Items[i] as TJSONObject;
      email := jsRow.Values['email'].Value;
      if jsRow.fieldAvaliable('firstname') then
        firstName := jsRow.Values['firstname'].Value
      else
        firstName := '';
      if jsRow.fieldAvaliable('lastname') then
        lastName := jsRow.Values['lastname'].Value
      else
        lastName := '';
      if jsRow.fieldAvaliable('company') then
        company := jsRow.Values['company'].Value
      else
        company := '';
      if jsRow.fieldAvaliable('book-isbn') then
        bookISBN := jsRow.Values['book-isbn'].Value
      else
        bookISBN := '';
      if jsRow.fieldAvaliable('book-title') then
        bookTitle := jsRow.Values['book-title'].Value
      else
        bookTitle := '';
      if jsRow.fieldAvaliable('rating') then
        rating := (jsRow.Values['rating'] as TJSONNumber).AsInt
      else
        rating := -1;
      if jsRow.fieldAvaliable('oppinion') then
        oppinion := jsRow.Values['oppinion'].Value
      else
        oppinion := '';
      // ----------------------------------------------------------------
      //
      // Validate imported Reader report
      //
      { TODO 2: [E] Move validation up. Before reading data }
      ValidateReadersReport(jsRow, email, dtReported);
      // ----------------------------------------------------------------
      //
      // Locate book by ISBN
      //
      { TODO 2: [G] Extract method }
      b := FBooksConfig.GetBookList(blkAll).FindByISBN(bookISBN);
      if not Assigned(b) then
        raise Exception.Create('Invalid book isbn');
      // ----------------------------------------------------------------
      // Find the Reader in then database using an email address
      readerId := MainDataModule.FindReaderByEmil(email);
      // ----------------------------------------------------------------
      //
      // Append a new reader into the database if requred:
      if System.Variants.VarIsNull(readerId) then
      begin
        { TODO 2: [G] Extract method }
        readerId := MainDataModule.GetMaxValueInDataSet
          (MainDataModule.mtabReaders, 'ReaderId') + 1;
        //
        // Fields: ReaderId, FirstName, LastName, Email, Company, BooksRead,
        // LastReport, ReadersCreated
        //
        MainDataModule.mtabReaders.AppendRecord([readerId, firstName, lastName,
          email, company, 1, dtReported, Now()]);
      end;
      // ----------------------------------------------------------------
      //
      // Append report into the database:
      // Fields: ReaderId, ISBN, Rating, Oppinion, Reported
      //
      MainDataModule.mtabReports.AppendRecord([readerId, bookISBN, rating,
        oppinion, dtReported]);
      // ----------------------------------------------------------------
      if Application.InDeveloperMode then
        Insert([rating.ToString], ss, maxInt);
    end;
    // ----------------------------------------------------------------
    if Assigned(MainFormFramePanel) and Assigned(MainFormChromeTabs) then
    begin
      with TSplitter.Create(frm) do
      begin
        Align := alBottom;
        Parent := frm;
        Height := 5;
      end;
      DBGrid1.Margins.Bottom := 0;
      DataSrc2 := TDataSource.Create(frm);
      DBGrid2 := TDBGrid.Create(frm);
      DBGrid2.AlignWithMargins := True;
      DBGrid2.Parent := frm;
      DBGrid2.Align := alBottom;
      DBGrid2.Height := frm.Height div 3;
      DBGrid2.DataSource := DataSrc2;
      DataSrc2.DataSet := MainDataModule.mtabReports;
      DBGrid2.Margins.Top := 0;
      DBGrid2.AutoSizeColumns();
    end;
  finally
    jsData.Free;
  end;
end;

end.
