unit ClientAPI.Readers;

interface

uses
  System.JSON;

function ImportReaderReportsFromWebService (const token:string): TJSONArray;

implementation

uses
  System.SysUtils, System.IOUtils;

function GetContactsFromService (const token:string): TJSONValue;
var
  JSONFileName: string;
  fname: string;
  FileContent: string;
begin
  JSONFileName := 'json\readers.json';
  if FileExists(JSONFileName) then
    fname := JSONFileName
  else if FileExists('..\..\'+JSONFileName) then
    fname := '..\..\'+JSONFileName
  else
    raise Exception.Create('Error Message');
  FileContent := TFile.ReadAllText(fname,TEncoding.UTF8);
  Result := TJSONObject.ParseJSONValue(FileContent);
end;

function ImportReaderReportsFromWebService (const token:string): TJSONArray;
var
  jsValue: TJSONValue;
begin
  jsValue := GetContactsFromService (token);
  if not Assigned(jsValue)then
    raise Exception.Create('Can''t connect with Open API service. No data')
  else if not( jsValue is TJSONArray ) then
  begin
    jsValue.Free;
    raise Exception.Create('Can''t load data form Open API service.');
  end;
  Result := jsValue as TJSONArray
end;

end.
