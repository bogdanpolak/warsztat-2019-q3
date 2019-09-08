unit DataAccess.Readers;

interface

uses
  Data.DB, System.SysUtils;

type
  IReadersDAO = interface(IInterface)
    ['{F8482010-9FCB-4994-B7E9-47F1DB115075}']
    function fldReaderId: TIntegerField;
    function fldEmail: TWideStringField;
    function fldFirstName: TWideStringField;
    function fldLastName: TWideStringField;
    function fldCompany: TWideStringField;
    function fldBooksRead: TIntegerField;
    function fldLastReport: TDateField;
    procedure ForEach(proc: TProc<IReadersDAO>);
  end;

implementation

end.
