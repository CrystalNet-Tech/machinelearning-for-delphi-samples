program AnomalyDetection_PhoneCalls;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SrEntireDetectionConsoleApp in 'SrEntireDetectionConsoleApp.pas',
  SrEntireDetection_Models in 'SrEntireDetection_Models.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TSrEntireDetectionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
