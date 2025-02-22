program LargeDatasets;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  LargeDatasets_Models in 'LargeDatasets_Models.pas',
  LargeDatasetsConsoleApp in 'LargeDatasetsConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas',
  ICSharpCode.SharpZipLib.Consts in '..\Common\Lib\ICSharpCode.SharpZipLib.Consts.pas',
  ICSharpCode.SharpZipLib.Intf in '..\Common\Lib\ICSharpCode.SharpZipLib.Intf.pas',
  ICSharpCode.SharpZipLib in '..\Common\Lib\ICSharpCode.SharpZipLib.pas';

begin
  try
    TLargeDatasetsConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
