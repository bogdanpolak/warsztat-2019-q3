program DUnitX_Books;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Test.ImportCommand in 'Test.ImportCommand.pas',
  Commnd.Import in '..\project\Commnd.Import.pas',
  Vcl.Pattern.Command in '..\project\Vcl.Pattern.Command.pas',
  Frame.Import in '..\project\Frame.Import.pas' {FrameImport: TFrame},
  ClientAPI.Books in '..\project\api\ClientAPI.Books.pas',
  Consts.Application in '..\project\Consts.Application.pas',
  Data.DataProxy.Factory in '..\project\proxy\Data.DataProxy.Factory.pas',
  Data.DataProxy in '..\project\proxy\Data.DataProxy.pas',
  Proxy.Books in '..\project\proxy\Proxy.Books.pas',
  Proxy.Readers in '..\project\proxy\Proxy.Readers.pas',
  Proxy.Reports in '..\project\proxy\Proxy.Reports.pas',
  Model.Books in '..\project\model\Model.Books.pas',
  Helper.TDBGrid in '..\project\Helper.TDBGrid.pas',
  Helper.TJSONObject in '..\project\Helper.TJSONObject.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
