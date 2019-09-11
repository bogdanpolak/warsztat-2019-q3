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
    constructor Create(Books: TBooksProxy); overload;
  end;

  TBookCollection2 = class(TObjectList<TBook2>)
  protected
  public
    function FindByISBN (const ISBN: string): TBook2;
    procedure Load(Books: TBooksProxy);
  end;

implementation

{ TBook }

constructor TBook2.Create(Books: TBooksProxy);
begin
  inherited Create;
  self.isbn := Books.ISBN.Value;
  self.title := Books.Title.Value;
  self.author := Books.Authors.Value;
  self.status := Books.Status.Value;
  self.releseDate := Books.ReleseDate.Value;
  self.pages := Books.Pages.Value;
  self.price := Books.Price.Value;
  self.currency := Books.Currency.Value;
  self.imported := Books.Imported.Value;
  self.description := Books.Description.Value;
end;

{ TBookCollection }

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

procedure TBookCollection2.Load(Books: TBooksProxy);
begin
  Books.ForEach(
    procedure
    begin
      self.Add(TBook2.Create(Books));
    end);
end;

end.
