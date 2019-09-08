unit DataAccess.Readers.FireDAC;

interface

uses
  Data.DB, System.SysUtils, FireDAC.Comp.DataSet,
  DataAccess.Base, DataAccess.Readers;

type
  TFDReadersDAO = class(TBaseDAO, IReadersDAO)
  strict private
    FFieldReaderId: TIntegerField;
    FFieldEmail: TWideStringField;
    FFieldFirstName: TWideStringField;
    FFieldLastName: TWideStringField;
    FFieldCompany: TWideStringField;
    FFieldBooksRead: TIntegerField;
    FFieldLastReport: TDateField;
  strict protected
    procedure BindDataSetFields(); override;
  public
    constructor Create(DataSet: TFDDataSet);
    function fldReaderId: TIntegerField;
    function fldEmail: TWideStringField;
    function fldFirstName: TWideStringField;
    function fldLastName: TWideStringField;
    function fldCompany: TWideStringField;
    function fldBooksRead: TIntegerField;
    function fldLastReport: TDateField;
    procedure ForEach(proc: TProc<IReadersDAO>);
  end;

function GetReader_FireDAC(DataSet: TFDDataSet): IReadersDAO;

implementation

procedure TFDReadersDAO.BindDataSetFields;
begin
  if Assigned(FDataSet) and FDataSet.Active then
  begin
    FFieldReaderId := FDataSet.FieldByName('ReaderId') as TIntegerField;
    FFieldEmail := FDataSet.FieldByName('Email') as TWideStringField;
    FFieldFirstName := FDataSet.FieldByName('FirstName') as TWideStringField;
    FFieldLastName := FDataSet.FieldByName('LastName') as TWideStringField;
    FFieldCompany := FDataSet.FieldByName('Company') as TWideStringField;
    FFieldBooksRead := FDataSet.FieldByName('BooksRead') as TIntegerField;
    FFieldLastReport := FDataSet.FieldByName('LastReport') as TDateField;
  end
  else
    raise Exception.Create('Error Message');
end;

constructor TFDReadersDAO.Create(DataSet: TFDDataSet);
begin
  inherited Create();
  LinkDataSet(DataSet, true);
end;

function TFDReadersDAO.fldBooksRead: TIntegerField;
begin
  Result := FFieldBooksRead;
end;

function TFDReadersDAO.fldCompany: TWideStringField;
begin
  Result := FFieldCompany;
end;

function TFDReadersDAO.fldEmail: TWideStringField;
begin
  Result := FFieldEmail;
end;

function TFDReadersDAO.fldFirstName: TWideStringField;
begin
  Result := FFieldFirstName;
end;

function TFDReadersDAO.fldLastName: TWideStringField;
begin
  Result := FFieldLastName;
end;

function TFDReadersDAO.fldLastReport: TDateField;
begin
  Result := FFieldLastReport;
end;

function TFDReadersDAO.fldReaderId: TIntegerField;
begin
  Result := FFieldReaderId;
end;

procedure TFDReadersDAO.ForEach(proc: TProc<IReadersDAO>);
begin
  FDataSet.First;
  while not FDataSet.Eof do
  begin
    proc(self);
    FDataSet.Next;
  end;
end;

function GetReader_FireDAC(DataSet: TFDDataSet): IReadersDAO;
begin
  Result := TFDReadersDAO.Create(DataSet);
end;

end.
