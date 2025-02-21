program AnomalyDetectionSales;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SpikeDetection_Models in 'SpikeDetection_Models.pas',
  SpikeDetectionConsoleApp in 'SpikeDetectionConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TSpikeDetectionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
