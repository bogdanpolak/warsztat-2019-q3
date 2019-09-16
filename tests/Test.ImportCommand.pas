unit Test.ImportCommand;

interface

uses
  DUnitX.TestFramework,
  System.Classes, System.SysUtils, Commnd.Import, Model.Books, Proxy.Books,
  Proxy.Readers, Proxy.Reports, Data.DataProxy.Factory;

{$M+}

type

  [TestFixture]
  TImportCommandFixture = class(TObject)
  private
    cmdImport: TTestImportCommand;
    FixtureOwner: TComponent;
    function ConstructBooks(BookProxy: TBooksProxy): TBookCollection;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  published
    procedure Test1;
  end;

implementation

uses
  System.Variants;

procedure TImportCommandFixture.Setup;
begin
  FixtureOwner := TComponent.Create(nil);
  cmdImport := TTestImportCommand.Create(FixtureOwner);
end;

procedure TImportCommandFixture.TearDown;
begin
  FixtureOwner.Free;
  cmdImport := nil;
end;

function TImportCommandFixture.ConstructBooks(BookProxy: TBooksProxy)
  : TBookCollection;
var
  Books :TBookCollection;
begin
  Books := TBookCollection.Create(True);
  BookProxy.ForEach(
    procedure
    begin
      Books.Add(BookProxy.ConstructBookModel);
    end);
  Result := Books;
end;

procedure TImportCommandFixture.Test1;
begin
  with cmdImport do
  begin
    BookProxy := TDataProxyFactory.CreateProxy<TBooksProxy>
      (FixtureOwner, TBooksProxy.CreateMockTable(FixtureOwner));
    ReaderProxy := TDataProxyFactory.CreateProxy<TReaderProxy>(FixtureOwner,
      TReaderProxy.CreateMockTable(FixtureOwner));
    ReportProxy := TDataProxyFactory.CreateProxy<TReportProxy>(FixtureOwner,
      TReportProxy.CreateMockTable(FixtureOwner));
    Books := self.ConstructBooks(BookProxy);
    Execute;
    Assert.Pass();
  end;
end;

end.
