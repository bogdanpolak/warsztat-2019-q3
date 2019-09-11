program BooksManager;

uses
  Vcl.Forms,
  Form.Main in 'Form.Main.pas' {Form1},
  Frame.Welcome in 'Frame.Welcome.pas' {FrameWelcome: TFrame},
  Fake.FDConnection in 'Fake.FDConnection.pas',
  Consts.Application in 'Consts.Application.pas',
  Utils.CipherAES128 in 'Utils.CipherAES128.pas',
  Frame.Import in 'Frame.Import.pas' {FrameImport: TFrame},
  Utils.General in 'Utils.General.pas',
  Data.Main in 'Data.Main.pas' {DataModMain: TDataModule},
  Utils.Messages in 'Utils.Messages.pas',
  Vcl.Themes,
  Vcl.Styles,
  DataAccess.Base in 'experimental\DataAccess.Base.pas',
  Scripts.Books in 'experimental\Scripts.Books.pas',
  DataAccess.Books in 'experimental\DataAccess.Books.pas',
  DataAccess.Books.FireDAC in 'experimental\DataAccess.Books.FireDAC.pas',
  ClientAPI.Books in 'api\ClientAPI.Books.pas',
  ClientAPI.Readers in 'api\ClientAPI.Readers.pas',
  ExtGUI.ListBox.Books in 'ExtGUI.ListBox.Books.pas',
  Consts.SQL in 'Consts.SQL.pas',
  Vcl.Pattern.Command in 'Vcl.Pattern.Command.pas',
  Command.Import in 'Command.Import.pas',
  Config.Application in 'Config.Application.pas',
  Helper.TDBGrid in 'Helper.TDBGrid.pas',
  Helper.TJSONObject in 'Helper.TJSONObject.pas',
  Helper.TApplication in 'Helper.TApplication.pas',
  Data.DataProxy.Factory in 'proxy\Data.DataProxy.Factory.pas',
  Data.DataProxy in 'proxy\Data.DataProxy.pas',
  Proxy.Books in 'proxy\Proxy.Books.pas',
  Proxy.Readers in 'proxy\Proxy.Readers.pas',
  Proxy.Reports in 'proxy\Proxy.Reports.pas',
  Model.Books in 'Model.Books.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDataModMain, DataModMain);
  Application.Run;
end.
