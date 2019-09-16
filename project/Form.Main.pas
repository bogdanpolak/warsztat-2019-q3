unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.DateUtils, System.Generics.Collections,
  System.JSON, System.Math, System.RegularExpressions,
  Data.DB,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.Pattern.Command,
  ChromeTabs, ChromeTabsClasses, ChromeTabsTypes,
  Fake.FDConnection,
  Frame.Welcome,
  {TODO 3: [D] Resolve dependency on ExtGUI.ListBox.Books. Too tightly coupled}
  // Dependency is requred by attribute TBooksListBoxConfigurator
  ExtGUI.ListBox.Books,
  Commnd.Import,
  Data.DataProxy,
  Data.DataProxy.Factory,
  Proxy.Books,
  Proxy.Readers,
  Proxy.Reports;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    lbBooksReaded: TLabel;
    Splitter1: TSplitter;
    lbBooksAvaliable: TLabel;
    lbxBooksReaded: TListBox;
    lbxBooksAvaliable2: TListBox;
    ChromeTabs1: TChromeTabs;
    pnMain: TPanel;
    btnImport: TButton;
    tmrAppReady: TTimer;
    Splitter2: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure tmrAppReadyTimer(Sender: TObject);
    procedure ChromeTabs1ButtonCloseTabClick(Sender: TObject; ATab: TChromeTab;
      var Close: Boolean);
    procedure ChromeTabs1Change(Sender: TObject; ATab: TChromeTab;
      TabChangeType: TTabChangeType);
    procedure FormResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
  private
    FBooksConfig: TBooksListBoxConfigurator;
    cmdImportReports: TImportCommand;
    procedure OnFormReady;
    procedure AutoSizeBooksGroupBoxes();
    procedure BuildDBGridForBooks_InternalQA(frm: TFrameWelcome);
    class function DBVersionToString(VerDB: Integer): string; static;
    procedure CreateAndShowWelcomeFrame(var frm: TFrameWelcome);
    function ConnectToDatabaseServer(frm: TFrameWelcome): Boolean;
    function IsCorrectDatabaseVersionNumber(frm: TFrameWelcome): Boolean;
    procedure BuildCommandsAndActions;
  public
    FDConnection1: TFDConnectionMock;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Consts.Application,
  Utils.CipherAES128,
  Frame.Import,
  Utils.General,
  Data.Main,
  Consts.SQL,
  Helper.TJSONObject,
  Helper.TApplication,
  Helper.TDBGrid;

const
  SecureKey = 'delphi-is-the-best';
  // SecurePassword = AES 128 ('masterkey',SecureKey)
  SecurePassword = 'hC52IiCv4zYQY2PKLlSvBaOXc14X41Mc1rcVS6kyr3M=';
  Client_API_Token = '20be805d-9cea27e2-a588efc5-1fceb84d-9fb4b67c';

resourcestring
  SWelcomeScreen = 'Welcome screen';
  SDBServerGone = 'Database server is gone';
  SDBConnectionUserPwdInvalid = 'Invalid database configuration.' +
    ' Application database user or password is incorrect.';
  SDBConnectionError = 'Can''t connect to database server. Unknown error.';
  SDBRequireCreate = 'Database is empty. You need to execute script' +
    ' creating required data.';
  SDBErrorSelect = 'Can''t execute SELECT command on the database';
  StrNotSupportedDBVersion = 'Not supported database version. Please' +
    ' update database structures.';

procedure TForm1.FormCreate(Sender: TObject);
begin
  if Application.InDeveloperMode then
    ReportMemoryLeaksOnShutdown := True;
  // !!! Please do not add here code if it's not required
  // !!! Place for the application initialization code is in the OnFormReady
end;

procedure TForm1.tmrAppReadyTimer(Sender: TObject);
begin
  tmrAppReady.Enabled := False;
  OnFormReady;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  AutoSizeBooksGroupBoxes();
end;

{ TODO 2: [Helper] TWinControl class helper }
function SumHeightForChildrens(Parent: TWinControl;
  ControlsToExclude: TArray<TControl>): Integer;
var
  i: Integer;
  ctrl: Vcl.Controls.TControl;
  isExcluded: Boolean;
  j: Integer;
  sumHeight: Integer;
  ctrlHeight: Integer;
begin
  sumHeight := 0;
  for i := 0 to Parent.ControlCount - 1 do
  begin
    ctrl := Parent.Controls[i];
    isExcluded := False;
    for j := 0 to Length(ControlsToExclude) - 1 do
      if ControlsToExclude[j] = ctrl then
        isExcluded := True;
    if not isExcluded then
    begin
      if ctrl.AlignWithMargins then
        ctrlHeight := ctrl.Height + ctrl.Margins.Top + ctrl.Margins.Bottom
      else
        ctrlHeight := ctrl.Height;
      sumHeight := sumHeight + ctrlHeight;
    end;
  end;
  Result := sumHeight;
end;

procedure TForm1.ChromeTabs1ButtonCloseTabClick(Sender: TObject;
  ATab: TChromeTab; var Close: Boolean);
var
  obj: TObject;
begin
  obj := TObject(ATab.Data);
  (obj as TFrame).Free;
end;

procedure TForm1.ChromeTabs1Change(Sender: TObject; ATab: TChromeTab;
  TabChangeType: TTabChangeType);
var
  obj: TObject;
begin
  if Assigned(ATab) then
  begin
    obj := TObject(ATab.Data);
    if (TabChangeType = tcActivated) and Assigned(obj) then
    begin
      HideAllChildFrames(pnMain);
      (obj as TFrame).Visible := True;
    end;
  end;
end;

procedure TForm1.AutoSizeBooksGroupBoxes();
var
  sum: Integer;
  avaliable: Integer;
  labelPixelHeight: Integer;
begin
  { TODO 3: Move into TBooksListBoxConfigurator }
  with TBitmap.Create do
  begin
    Canvas.Font.Size := GroupBox1.Font.Height;
    labelPixelHeight := Canvas.TextHeight('Zg');
    Free;
  end;
  sum := SumHeightForChildrens(GroupBox1, [lbxBooksReaded, lbxBooksAvaliable2]);
  avaliable := GroupBox1.Height - sum - labelPixelHeight;
  if GroupBox1.AlignWithMargins then
    avaliable := avaliable - GroupBox1.Padding.Top - GroupBox1.Padding.Bottom;
  if lbxBooksReaded.AlignWithMargins then
    avaliable := avaliable - lbxBooksReaded.Margins.Top -
      lbxBooksReaded.Margins.Bottom;
  if lbxBooksAvaliable2.AlignWithMargins then
    avaliable := avaliable - lbxBooksAvaliable2.Margins.Top -
      lbxBooksAvaliable2.Margins.Bottom;
  lbxBooksReaded.Height := avaliable div 2;
end;

procedure TForm1.BuildDBGridForBooks_InternalQA(frm: TFrameWelcome);
var
  datasrc: TDataSource;
  DataGrid: TDBGrid;
begin
  datasrc := TDataSource.Create(frm);
  DataGrid := TDBGrid.Create(frm);
  DataGrid.AlignWithMargins := True;
  DataGrid.Parent := frm;
  DataGrid.Align := alClient;
  DataGrid.DataSource := datasrc;
  datasrc.DataSet := DataModMain.mtabBooks;
  DataGrid.AutoSizeColumns();
end;

procedure TForm1.Splitter1Moved(Sender: TObject);
begin
  (Sender as TSplitter).Tag := 1;
end;

class function TForm1.DBVersionToString(VerDB: Integer): string;
begin
  Result := (VerDB div 1000).ToString + '.' + (VerDB mod 1000).ToString;
end;

procedure TForm1.BuildCommandsAndActions;
begin
  cmdImportReports := TImportCommand.Create(Self);
  with cmdImportReports do
  begin
    MainFormChromeTabs := Self.ChromeTabs1;
    MainFormFramePanel := Self.pnMain;
    FBooksConfig := Self.FBooksConfig;
    BookProxy := TDataProxyFactory.CreateProxy<TBooksProxy>(Self,
      DataModMain.mtabBooks);
    ReaderProxy := TDataProxyFactory.CreateProxy<TReaderProxy>(Self,
      DataModMain.mtabReaders);
    ReportProxy := TDataProxyFactory.CreateProxy<TReportProxy>(Self,
      DataModMain.mtabReports);

  end;
  btnImport.Action := TCommandAction.Create(Self);
  with (btnImport.Action as TCommandAction) do
  begin
    Caption := 'Import Reports';
    Command := cmdImportReports;
  end;
end;

procedure TForm1.CreateAndShowWelcomeFrame(var frm: TFrameWelcome);
var
  tab: TChromeTab;
begin
  frm := TFrameWelcome.Create(pnMain);
  frm.Parent := pnMain;
  frm.Visible := True;
  frm.Align := alClient;
  tab := ChromeTabs1.Tabs.Add;
  tab.Caption := 'Welcome';
  tab.Data := frm;
end;

function TForm1.ConnectToDatabaseServer(frm: TFrameWelcome): Boolean;
var
  msg1: string;
  UserName: string;
  password: string;
begin
  // 1) Connect to database server
  // 2) Checks application user
  Result := False;
  try
    UserName := FDManager.ConnectionDefs.ConnectionDefByName
      (FDConnection1.ConnectionDefName).Params.UserName;
    password := AES128_Decrypt(SecurePassword, SecureKey);
    FDConnection1.Open(UserName, password);
    Result := True;
  except
    on E: EFDDBEngineException do
    begin
      case E.kind of
        ekUserPwdInvalid:
          msg1 := SDBConnectionUserPwdInvalid;
        ekServerGone:
          msg1 := SDBServerGone;
      else
        msg1 := SDBConnectionError;
      end;
      frm.AddInfo(0, msg1, True);
      frm.AddInfo(1, E.Message, False);
    end;
  end;
end;

function TForm1.IsCorrectDatabaseVersionNumber(frm: TFrameWelcome): Boolean;
var
  res: Variant;
  msg1: string;
  VersionNr: Integer;
begin
  // Checks database structure (DB version)
  Result := False;
  try
    res := FDConnection1.ExecSQLScalar(SQL_SELECT_DatabaseVersion);
  except
    on E: EFDDBEngineException do
    begin
      msg1 := IfThen(E.kind = ekObjNotExists, SDBRequireCreate, SDBErrorSelect);
      frm.AddInfo(0, msg1, True);
      frm.AddInfo(1, E.Message, False);
      exit;
    end;
  end;
  VersionNr := res;
  Result := (VersionNr = ExpectedDatabaseVersionNr);
  if not Result then
  begin
    frm.AddInfo(0, StrNotSupportedDBVersion, True);
    frm.AddInfo(1, 'Oczekiwana wersja bazy: ' +
      DBVersionToString(ExpectedDatabaseVersionNr), True);
    frm.AddInfo(1, 'Aktualna wersja bazy: ' + DBVersionToString
      (VersionNr), True);
    exit;
  end;
end;

procedure TForm1.OnFormReady;
var
  frm: TFrameWelcome;
begin
  pnMain.Caption := '';
  CreateAndShowWelcomeFrame(frm);
  if not ConnectToDatabaseServer(frm) then
    exit;
  if not IsCorrectDatabaseVersionNumber(frm) then
    exit;
  DataModMain.OpenDataSets;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // * Initialize ListBox'es for books
  // * Load books form database
  // * Setup drag&drop functionality for two list boxes
  // * Setup OwnerDraw mode
  //
  FBooksConfig := TBooksListBoxConfigurator.Create(Self);
  FBooksConfig.PrepareListBoxes(lbxBooksReaded, lbxBooksAvaliable2);
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  BuildCommandsAndActions;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  if Application.InDeveloperMode and InInternalQualityMode then
  begin
    BuildDBGridForBooks_InternalQA(frm);
  end;
end;

end.
