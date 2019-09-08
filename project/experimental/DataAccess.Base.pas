unit DataAccess.Base;

interface

uses
  Data.DB, System.SysUtils;

type
  TDAOConfig = class
  strict private
    FAutoOpenDataSet: Boolean;
  public
    property AutoOpenDataSet: Boolean read FAutoOpenDataSet
      write FAutoOpenDataSet;
  end;

  TBaseDAO = class(TInterfacedObject)
  strict private
    FConfig: TDAOConfig;
  strict protected
    FDataSet: TDataSet;
    FDataSetReady: Boolean;
    procedure BindDataSetFields(); virtual; abstract;
  public
    procedure VerifyIsStateValid;
    constructor Create();
    destructor Destroy; override;
    function GetConfig: TDAOConfig;
    procedure LinkDataSet(dataset: TDataSet; isOpen: Boolean);
    function Next: Boolean;
  end;

implementation

constructor TBaseDAO.Create;
begin
  inherited;
  FConfig := TDAOConfig.Create();
end;

destructor TBaseDAO.Destroy;
begin
  FConfig.Free;
  inherited;
end;

function TBaseDAO.GetConfig: TDAOConfig;
begin
  Result := FConfig;
end;

procedure TBaseDAO.VerifyIsStateValid;
begin
  if not FDataSetReady then
    raise Exception.Create
      ('DAO Object isnt linked with dataset. Please call LinkDataSet method in advance.')
  else if not(FDataSet.Active) then
    raise Exception.Create
      ('Dataset is closed. Cant manipulate on the closed dataset using DAO object');
end;

procedure TBaseDAO.LinkDataSet(dataset: TDataSet; isOpen: Boolean);
begin
  FDataSet := dataset;
  if isOpen and not(dataset.Active) then
    dataset.Open;
  BindDataSetFields();
  FDataSetReady := true;
end;

function TBaseDAO.Next: Boolean;
begin
  VerifyIsStateValid;
  FDataSet.Next;
  Result := not FDataSet.Eof;
end;

end.
