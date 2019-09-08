unit Fake.FDConnection;

interface

uses
  System.SysUtils;

type
  TFDCommandExceptionKind = (ekOther, ekNoDataFound, ekTooManyRows,
    ekRecordLocked, ekUKViolated, ekFKViolated, ekObjNotExists,
    ekUserPwdInvalid, ekUserPwdExpired, ekUserPwdWillExpire, ekCmdAborted,
    ekServerGone, ekServerOutput, ekArrExecMalfunc, ekInvalidParams);

  EFDDBEngineException = class(Exception)
    kind: TFDCommandExceptionKind;
  end;

  TFDConnectionDefParams = record
    function UserName: string;
  end;

  TFDStanConnectionDef = record
    Params: TFDConnectionDefParams;
  end;

  TConnectionDefs = record
    function ConnectionDefByName(const AName: string): TFDStanConnectionDef;
  end;

  TFDConnectionMock = record
    function ConnectionDefName: string;
    procedure Open(); overload;
    procedure Open(const AUserName, APassword: string); overload;
    function ExecSQLScalar(const ASQL: String): Variant;
  end;

  TFDManagerMock = record
    function ConnectionDefs: TConnectionDefs;
  end;

var
  FDManager: TFDManagerMock;

implementation

{ TFDConnectionMock }

function TFDConnectionMock.ConnectionDefName: string;
begin
  Result := 'IB_Mailing';
end;

function TFDConnectionMock.ExecSQLScalar(const ASQL: String): Variant;
begin
  Result := 2001;
end;

type
  RecError = record
    kind: TFDCommandExceptionKind;
    msg: string;
  end;

const
  DatabaseErrors: array [1 .. 3] of RecError = ((kind: ekServerGone;
    msg: '[FireDAC] Unavailable database'), (kind: ekUserPwdInvalid;
    msg: '[FireDAC] Your user name and password are not defined. Ask your database administrator to set up a login.'),
    (kind: ekObjNotExists;
    msg: '[FireDAC] Dynamic SQL Error (code = -204) Table unknown: DBINFO'));

procedure TFDConnectionMock.Open;
var
  E: EFDDBEngineException;
  RaiseErrorNr: Integer;
begin
  RaiseErrorNr := 0;
  if RaiseErrorNr>0 then
  begin
    E := EFDDBEngineException.Create(DatabaseErrors[RaiseErrorNr].msg);
    E.kind := DatabaseErrors[RaiseErrorNr].kind;
    raise E;
  end;
end;

procedure TFDConnectionMock.Open(const AUserName, APassword: string);
begin
   self.Open
end;

{ TConnectionDefs }

function TConnectionDefs.ConnectionDefByName(const AName: string)
  : TFDStanConnectionDef;
var
  cdp: TFDStanConnectionDef;
begin
  Result := cdp;
end;

{ TFDConnectionDefParams }

function TFDConnectionDefParams.UserName: string;
begin
  Result := 'sysdba';
end;

{ TFDManagerMock }

function TFDManagerMock.ConnectionDefs: TConnectionDefs;
var
  ConDefs: TConnectionDefs;
begin
  Result := ConDefs;
end;

end.
