program IrisClassification;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  IrisClassification_Models in 'IrisClassification_Models.pas',
  IrisClassificationConsoleApp in 'IrisClassificationConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TIrisClassificationConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
