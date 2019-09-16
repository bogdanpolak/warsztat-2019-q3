unit Model.Books;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  TBook = class
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

  TBookCollection = class(TObjectList<TBook>)
  private
  protected
  public
    function FindByISBN (const ISBN: string): TBook;
    function ConstructBooksAvaliable: TBookCollection;
    function ConstructBooksOnShelf: TBookCollection;
  end;

implementation

function TBookCollection.FindByISBN(const ISBN: string): TBook;
var
  b: TBook;
begin
  for b in Self do
    if b.isbn = ISBN then
    begin
      Result := b;
      exit;
    end;
  Result := nil;
end;

function TBookCollection.ConstructBooksOnShelf: TBookCollection;
var
  b: TBook;
begin
  Result := TBookCollection.Create(false);
  for b in Self do
    if b.status = 'on-shelf' then
      Result.Add(b)
end;

function TBookCollection.ConstructBooksAvaliable: TBookCollection;
var
  b: TBook;
begin
  Result := TBookCollection.Create(false);
  for b in Self do
    if b.status = 'avaliable' then
      Result.Add(b)
end;

end.
