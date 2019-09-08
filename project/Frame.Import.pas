unit Frame.Import;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TFrameImport = class(TFrame)
    tmrFrameReady: TTimer;
    procedure tmrFrameReadyTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrameImport.tmrFrameReadyTimer(Sender: TObject);
begin
  tmrFrameReady.Enabled := False;
end;

end.
