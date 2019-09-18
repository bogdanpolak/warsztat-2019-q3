unit Test.ImportCommand;

interface

uses
  DUnitX.TestFramework,
  System.Classes, System.SysUtils, Commnd.Import, Model.Books, Proxy.Books,
  Proxy.Readers, Proxy.Reports, Data.DataProxy.Factory;

{$M+}

type

  [TestFixture]
  TImportCommandFixture = class(TObject)
  private
    cmdImport: TTestImportCommand;
    FixtureOwner: TComponent;
    function ConstructBooks(BookProxy: TBooksProxy): TBookCollection;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  published
    procedure Test1;
  end;

implementation

uses
  System.Variants;

procedure TImportCommandFixture.Setup;
begin
  FixtureOwner := TComponent.Create(nil);
  cmdImport := TTestImportCommand.Create(FixtureOwner);
  with cmdImport do
  begin
    BookProxy := TBooksProxy.CreateMock(FixtureOwner);
    ReaderProxy := TReaderProxy.CreateMock(FixtureOwner);
    ReportProxy := TReportProxy.CreateMock(FixtureOwner);
  end;
end;

procedure TImportCommandFixture.TearDown;
begin
  FixtureOwner.Free;
  cmdImport := nil;
end;

function TImportCommandFixture.ConstructBooks(BookProxy: TBooksProxy)
  : TBookCollection;
var
  Books: TBookCollection;
begin
  Books := TBookCollection.Create(True);
  BookProxy.ForEach(
    procedure
    begin
      Books.Add(BookProxy.ConstructBookModel);
    end);
  Result := Books;
end;

procedure TImportCommandFixture.Test1;
begin
  with cmdImport do
  begin
    BookProxy.AppendRecord(['1234', 'Book title', 'Book author/s', 'on-shelf',
      EncodeDate(2019, 1, 1), 400, 59.99, 'USD', EncodeDate(2010, 9, 1),
      'Long book descitpion']);
    Books := self.ConstructBooks(BookProxy);
    // ------
    MockJsonDataBooks := '[{' + '"status": "cooming-soon",' +
      '"title": "Hands-On Design Patterns with C# and .NET Core",' +
      '"isbn": "978-1788625258",' +
      '"author": "Gaurav Aroraa, Jeffrey Chilberto",' + '"date": "Jan 2019",' +
      '"pages": 437,' + '"price": 25.83,' + '"currency": "EUR",' +
      '"description": "Short book description is here"' + '}]';
    MockJsonDataReports := '[{"firstname": "Sobieraj", ' +
      '"lastname": "Stanislaw", "email": "staszek.sobieraj@empik.com",' +
      '"company": "", "book-isbn": "1234", "book-title": "Book title",' +
      '"rating": 10, "oppinion": "Great and easy",' +
      '"created": "2018-07-27T18:30:49Z"' + '}]';
  end;
  cmdImport.Execute;
  Assert.AreEqual(2, cmdImport.BookProxy.RecordCount,
    '(BookProxy.RecordCount)');
  Assert.AreEqual(2, cmdImport.Books.Count, 'cmdImport.Books.Count');
  Assert.AreEqual(1, cmdImport.ReportProxy.RecordCount,
    'ReportProxy.RecordCount');
  Assert.AreEqual(1, cmdImport.ReaderProxy.RecordCount,
    'ReaderProxy.RecordCount');
end;

end.
