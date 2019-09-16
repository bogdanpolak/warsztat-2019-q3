unit ClientAPI.Books;

interface

uses
  System.JSON;

type
  TWebServiceBooks = class
  private
    class function GetReports(const token: string): TJSONValue;
    class function GetBooks(const token: string): TJSONValue;
  public
    class function ImportReaderReports(const token: string): TJSONArray;
    class function ImportBooks(const token: string): TJSONArray;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

class function TWebServiceBooks.GetBooks(const token: string): TJSONValue;
var
  JSONFileName: string;
  fname: string;
  FileContent: string;
begin
  JSONFileName := 'json\books.json';
  if FileExists(JSONFileName) then
    fname := JSONFileName
  else if FileExists('..\..\' + JSONFileName) then
    fname := '..\..\' + JSONFileName
  else
    raise Exception.Create('Error Message');
  FileContent := TFile.ReadAllText(fname, TEncoding.UTF8);
  Result := TJSONObject.ParseJSONValue(FileContent);
end;

class function TWebServiceBooks.ImportBooks(const token: string): TJSONArray;
var
  jsValue: TJSONValue;
begin
  jsValue := GetBooks(token);
  if jsValue is TJSONArray then
    Result := jsValue as TJSONArray
  else
  begin
    jsValue.Free;
    Result := nil;
  end;
end;

class function TWebServiceBooks.GetReports(const token: string): TJSONValue;
var
  JSONFileName: string;
  fname: string;
  FileContent: string;
begin
  JSONFileName := 'json\readers.json';
  if FileExists(JSONFileName) then
    fname := JSONFileName
  else if FileExists('..\..\' + JSONFileName) then
    fname := '..\..\' + JSONFileName
  else
    raise Exception.Create('Error Message');
  FileContent := TFile.ReadAllText(fname, TEncoding.UTF8);
  Result := TJSONObject.ParseJSONValue(FileContent);
end;

class function TWebServiceBooks.ImportReaderReports(const token: string)
  : TJSONArray;
var
  jsValue: TJSONValue;
begin
  jsValue := GetReports(token);
  if not Assigned(jsValue) then
    raise Exception.Create('Can''t connect with Open API service. No data')
  else if not(jsValue is TJSONArray) then
  begin
    jsValue.Free;
    raise Exception.Create('Can''t load data form Open API service.');
  end;
  Result := jsValue as TJSONArray
end;

end.
