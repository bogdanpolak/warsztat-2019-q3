unit DataAccess.Books;

interface

uses
  Data.DB, System.SysUtils;

type
  IBooksDAO = interface(IInterface)
    ['{F8482010-9FCB-4994-B7E9-47F1DB115075}']
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


implementation

end.
