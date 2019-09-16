unit Test.ImportCommand;

interface

uses
  DUnitX.TestFramework,
  System.Classes, System.SysUtils;

{$M+}

type
  [TestFixture]
  TImportCommandFixture = class(TObject)
  private
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

end;

procedure TImportCommandFixture.TearDown;
begin

end;


procedure TImportCommandFixture.Test1;
begin

end;

end.
