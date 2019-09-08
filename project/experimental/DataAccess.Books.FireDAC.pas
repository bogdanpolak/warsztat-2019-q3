unit DataAccess.Books.FireDAC;

interface

uses
  Data.DB, System.SysUtils, FireDAC.Comp.DataSet,
  DataAccess.Base, DataAccess.Books;

type
  TFDBooksDAO = class(TBaseDAO, IBooksDAO)
  strict private
    FFieldISBN: TWideStringField;
    FFieldTitle: TWideStringField;
    FFieldAuthors: TWideStringField;
    FFieldStatus: TWideStringField;
    FFieldReleseDate: TDateField;
    FFieldPages: TIntegerField;
    FFieldPrice: TCurrencyField;
    FFieldCurrency: TWideStringField;
    FFieldImported: TDateField;
    FFieldDescription: TWideStringField;
  strict protected
    procedure BindDataSetFields(); override;
  public
    constructor Create(DataSet: TFDDataSet);
    function fldISBN: TWideStringField;
    function fldTitle: TWideStringField;
    function fldAuthors: TWideStringField;
    function fldStatus: TWideStringField;
    function fldReleseDate: TDateField;
    function fldPages: TIntegerField;
    function fldPrice: TCurrencyField;
    function fldCurrency: TWideStringField;
    function fldImported: TDateField;
    function fldDescription: TWideStringField;
    procedure ForEach(proc: TProc<IBooksDAO>);
  end;

function GetBooks_FireDAC(DataSet: TFDDataSet): IBooksDAO;

implementation

procedure TFDBooksDAO.BindDataSetFields;
begin
  if Assigned(FDataSet) and FDataSet.Active then
  begin
    FFieldISBN := FDataSet.FieldByName('ISBN') as TWideStringField;
    FFieldTitle := FDataSet.FieldByName('Title') as TWideStringField;
    FFieldAuthors := FDataSet.FieldByName('Authors') as TWideStringField;
    FFieldStatus := FDataSet.FieldByName('Status') as TWideStringField;
    FFieldReleseDate := FDataSet.FieldByName('ReleseDate') as  TDateField;
    FFieldPages := FDataSet.FieldByName('Pages') as TIntegerField;
    FFieldPrice := FDataSet.FieldByName('Price') as TCurrencyField;
    FFieldCurrency := FDataSet.FieldByName('Currency') as TWideStringField;
    FFieldImported := FDataSet.FieldByName('Imported') as TDateField;
    FFieldDescription := FDataSet.FieldByName('Description') as TWideStringField;
  end
  else
    raise Exception.Create('Error Message');
end;

constructor TFDBooksDAO.Create(DataSet: TFDDataSet);
begin
  inherited Create();
  LinkDataSet(DataSet, true);
end;


function TFDBooksDAO.fldAuthors: TWideStringField;
begin
  Result := FFieldISBN;
end;

function TFDBooksDAO.fldCurrency: TWideStringField;
begin
  Result := FFieldCurrency
end;

function TFDBooksDAO.fldDescription: TWideStringField;
begin
  Result := FFieldDescription
end;

function TFDBooksDAO.fldImported: TDateField;
begin
  Result := FFieldImported;
end;

function TFDBooksDAO.fldISBN: TWideStringField;
begin
  Result := FFieldISBN;
end;

function TFDBooksDAO.fldPages: TIntegerField;
begin
  Result := FFieldPages;
end;

function TFDBooksDAO.fldPrice: TCurrencyField;
begin
  Result := FFieldPrice;
end;

function TFDBooksDAO.fldReleseDate: TDateField;
begin
  Result := FFieldReleseDate;
end;

function TFDBooksDAO.fldStatus: TWideStringField;
begin
  Result := FFieldStatus;
end;

function TFDBooksDAO.fldTitle: TWideStringField;
begin
  Result := FFieldTitle;
end;

procedure TFDBooksDAO.ForEach(proc: TProc<IBooksDAO>);
begin
  FDataSet.First;
  while not FDataSet.Eof do
  begin
    proc(self);
    FDataSet.Next;
  end;
end;

function GetBooks_FireDAC(DataSet: TFDDataSet): IBooksDAO;
begin
  Result := TFDBooksDAO.Create(DataSet);
end;

end.
