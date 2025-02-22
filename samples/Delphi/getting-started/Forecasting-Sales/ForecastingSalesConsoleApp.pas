unit ForecastingSalesConsoleApp;

// https://github.com/dotnet/machinelearning-samples/tree/main/samples/csharp/end-to-end-apps/Forecasting-Sales

interface

type
  TForecastingSalesConsoleApp = class
  public
    class procedure Run;
  end;

implementation

uses CNCoreClrLib.ExceptionMgr, ConsoleHelperExt, MLContextMgr,
  RegressionProductModelHelper, TimeSeriesModelHelper, ConsoleHelper;

const
  BaseDatasetsRelativePath = '..\..\Data';
  ProductDataRelativePath = BaseDatasetsRelativePath + '\products.stats.csv';

{ TForecastingSalesConsoleApp }

class procedure TForecastingSalesConsoleApp.Run;
var
  ProductDataPath: string;
begin
  try
    ProductDataPath := GetAbsolutePath(ProductDataRelativePath);

    // This sample shows two different ML tasks and algorithms that can be used for forecasting:
    // 1.) Regression using FastTreeTweedie Regression
    // 2.) Time Series using Single Spectrum Analysis
    // Each of these techniques are used to forecast monthly units for the same products so that you can compare the forecasts.

    var mlContext := TMLContextManager.Create(1);  //Seed set to any number so you have a deterministic environment

    ConsoleWriteHeader(['Forecast using Regression model']);

    TrainAndSaveModel(mlContext, ProductDataPath);
    TestPrediction(mlContext);

    ConsoleWriteHeader(['Forecast using Time Series SSA estimation']);

    PerformTimeSeriesProductForecasting(mlContext, ProductDataPath);
  except
    on Ex: ECoreClrException do
    begin
      ConsoleWriteException([Ex.ToString()]);
      ConsolePressAnyKey();
    end;
  end;
end;

end.
