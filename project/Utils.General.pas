unit Utils.General;

interface

uses
  Vcl.Controls;

{ TODO 2: [Helper] TWinControl class helper }
procedure HideAllChildFrames(AParenControl: TWinControl);

implementation

uses
  Vcl.Forms;

procedure HideAllChildFrames(AParenControl: TWinControl);
var
  i: Integer;
begin
  for i := AParenControl.ControlCount - 1 downto 0 do
    if AParenControl.Controls[i] is TFrame then
      (AParenControl.Controls[i] as TFrame).Visible := False;
end;


end.
