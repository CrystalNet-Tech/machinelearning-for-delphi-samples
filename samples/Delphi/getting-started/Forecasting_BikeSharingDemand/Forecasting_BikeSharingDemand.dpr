program Forecasting_BikeSharingDemand;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  BikeDemandForecastingConsoleApp in 'BikeDemandForecastingConsoleApp.pas',
  BikeDemandForecasting_Models in 'BikeDemandForecasting_Models.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TBikeDemandForecastingConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
