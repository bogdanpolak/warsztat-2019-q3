unit Scripts.Books;

interface

uses
  System.Classes;

type
  TBooksScripts = class
    class function GetFirstNameList: string;
  end;

implementation

uses
  Data.Main, System.SysUtils,
  DataAccess.Books, DataAccess.Books.FireDAC;

const
  TEXT_SPERATOR = ', ';

class function TBooksScripts.GetFirstNameList: string;
var
  Books: IBooksDAO;
  s: string;
begin
  Books := GetBooks_FireDAC(DataModMain.mtabBooks);
  s := '';
  Books.ForEach(
    procedure(row: IBooksDAO)
    begin
      if not row.fldTitle.Value.Trim.IsEmpty then
        if s.IsEmpty then
          s := row.fldTitle.Value
        else
          s := s + TEXT_SPERATOR + row.fldTitle.Value;
    end);
  Result := s;
end;

end.
