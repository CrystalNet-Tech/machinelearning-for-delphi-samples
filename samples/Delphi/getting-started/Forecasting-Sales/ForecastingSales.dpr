program ForecastingSales;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ConsoleHelperExt in 'ConsoleHelperExt.pas',
  ForecastingSales_Models in 'ForecastingSales_Models.pas',
  ForecastingSalesConsoleApp in 'ForecastingSalesConsoleApp.pas',
  RegressionProductModelHelper in 'RegressionProductModelHelper.pas',
  SampleProductData in 'SampleProductData.pas',
  TimeSeriesModelHelper in 'TimeSeriesModelHelper.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TForecastingSalesConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
