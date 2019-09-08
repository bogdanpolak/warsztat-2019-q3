unit ClientAPI.Books;

interface

uses
  System.JSON;

function ImportBooksFromWebService (const token:string): TJSONArray;

implementation

uses
  System.SysUtils, System.IOUtils;

function GetBooksFromService (const token:string): TJSONValue;
var
  JSONFileName: string;
  fname: string;
  FileContent: string;
begin
  JSONFileName := 'json\books.json';
  if FileExists(JSONFileName) then
    fname := JSONFileName
  else if FileExists('..\..\'+JSONFileName) then
    fname := '..\..\'+JSONFileName
  else
    raise Exception.Create('Error Message');
  FileContent := TFile.ReadAllText(fname,TEncoding.UTF8);
  Result := TJSONObject.ParseJSONValue(FileContent);
end;

function ImportBooksFromWebService (const token:string): TJSONArray;
var
  jsValue: TJSONValue;
begin
  jsValue := GetBooksFromService (token);
  if jsValue is TJSONArray then
    Result := jsValue as TJSONArray
  else begin
    jsValue.Free;
    Result := nil;
  end;
end;

end.
