program DatabaseLoader;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DatabaseLoader_Models in 'DatabaseLoader_Models.pas',
  DatabaseLoaderConsoleApp in 'DatabaseLoaderConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TDatabaseLoaderConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
