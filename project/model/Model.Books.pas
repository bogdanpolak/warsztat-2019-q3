unit Model.Books;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Proxy.Books;

type
  TBook2 = class
    status: string;
    title: string;
    isbn: string;
    author: string;
    releseDate: TDateTime;
    pages: integer;
    price: currency;
    currency: string;
    imported: TDateTime;
    description: string;
  end;

  TBookCollection2 = class(TObjectList<TBook2>)
  protected
  public
    function FindByISBN (const ISBN: string): TBook2;
  end;

implementation

function TBookCollection2.FindByISBN(const ISBN: string): TBook2;
var
  b: TBook2;
begin
  for b in Self do
    if b.isbn = ISBN then
    begin
      Result := b;
      exit;
    end;
  Result := nil;
end;

end.
