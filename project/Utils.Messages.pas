unit Utils.Messages;

interface

uses
  Winapi.Messages, Winapi.Windows,
  Vcl.Forms,
  System.Classes, System.Contnrs;

const
  WM_FRAME_MESSAGE = WM_USER + 101;

type
  TMyMessage = class
    Kind: string;
    Text: string;
    TagInteger: integer;
    TagFloat: double;
    TagBoolean: boolean;
    Data: Pointer;
    Obj: TObject;
  end;

  TMessages = class(TObjectList)
  private
    function GetItem(Index: integer): TMyMessage; inline;
    procedure SetItem(Index: integer; AMessage: TMyMessage); inline;
  public
    Listeners: Array of TFrame;
    function Add(msg: TMyMessage): integer; inline;
    property Items[Index: integer]: TMyMessage read GetItem
      write SetItem; default;
    procedure RegisterListener(frm: TFrame);
    procedure ProcessMessages;
  end;

implementation

function TMessages.Add(msg: TMyMessage): integer;
begin
  Result := inherited Add(msg);
end;

function TMessages.GetItem(Index: integer): TMyMessage;
var
  Obj: TObject;
begin
  Obj := inherited GetItem(Index);
  Result := Obj as TMyMessage;
end;

procedure TMessages.ProcessMessages;
var
  i: integer;
  msg: TMyMessage;
  j: integer;
  frame: TFrame;
begin
  // TODO 3: Migrate to System.Messaging
  for i := 0 to self.Count - 1 do
  begin
    msg := self.Items[i];
    for j := 0 to Length(Listeners) - 1 do
    begin
      frame := Listeners[j];
      SendMessage(frame.Handle, WM_FRAME_MESSAGE, 1, NativeInt(msg));
    end;
  end;
  self.Clear;
end;

procedure TMessages.RegisterListener(frm: TFrame);
var
  n: integer;
begin
  n := Length(Listeners);
  SetLength(Listeners, n + 1);
  Listeners[n] := frm;
end;

procedure TMessages.SetItem(Index: integer; AMessage: TMyMessage);
begin
  inherited SetItem(Index, AMessage);
end;

end.
