program PowerAnomalyDetection;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  PowerAnomalyDetection_Models in 'PowerAnomalyDetection_Models.pas',
  PowerAnomalyDetectionConsoleApp in 'PowerAnomalyDetectionConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TPowerAnomalyDetectionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
