unit ConsoleHelper;

interface

uses CrystalNet.Console, Microsoft.ML.Data.Intf, CrystalNet.Runtime.Intf, CrystalNet.Runtime,
  Microsoft.ML.DataView.Intf, Microsoft.ML.Core.Intf, CrystalNet.Console.Enums, Microsoft.ML.Data,
  CNCoreClrLib.CollectionMgr, System.Generics.Collections, MLMetrics, MLData, MLContextMgr, MLCore,
  SysUtils, MLCollections, MLTransforms;

//type
//  TMLEnumerableHelper = class
//  public
//    class function Take<T>(AArray: TArray<T>; Count: Integer): TArray<T>;
//    class function Select<T, U>(AArray: TArray<T>; SelectFunc: TFunc<T, U>): TArray<U>; overload;
//    class function Select<T, U>(AList: TList<T>; SelectFunc: TFunc<T, U>): TArray<U>; overload;
//    class function Last<T>(AArray: TArray<T>): T;
//  end;

procedure PrintPrediction(prediction: string);
procedure PrintRegressionPredictionVersusObserved(predictionCount, observedCount: string);
procedure PrintRegressionMetrics(name: string; metrics: IMLRegressionMetrics);
procedure PrintBinaryClassificationMetrics(name: string; metrics: ICalibratedBinaryClassificationMetrics);
procedure PrintAnomalyDetectionMetrics(name: string; metrics: IAnomalyDetectionMetrics);
procedure PrintMultiClassClassificationMetrics(name: string; metrics: IMLMulticlassClassificationMetrics);
procedure PrintRegressionFoldsAverageMetrics(algorithmName: string; crossValidationResults: Enumerable<IMLCrossValidationResult<IMLRegressionMetrics>>);
procedure PrintMulticlassClassificationFoldsAverageMetrics(algorithmName: string; crossValResults: Enumerable<IMLCrossValidationResult<IMLMulticlassClassificationMetrics>>);
function CalculateStandardDeviation (values: Enumerable<Double>): Double;
function CalculateConfidenceInterval95(values: Enumerable<double>): Double;
procedure PrintClusteringMetrics(name: string; metrics: IClusteringMetrics);
procedure ShowDataViewInConsole(const mlContext: IMLContextManager; dataView: IMLDataView; numberOfRows: Integer = 4);
procedure PeekDataViewInConsole(const mlContext: IMLContextManager; dataView: IMLDataView; pipeline: IMLEstimatorChain<IMLTransformer>; numberOfRows: Integer = 4); overload;
procedure PeekDataViewInConsole(const mlContext: IMLContextManager; dataView: IMLDataView; pipeline: IMLValueMappingEstimator; numberOfRows: Integer = 4); overload;
procedure PeekVectorColumnDataInConsole(const mlContext: IMLContextManager; columnName: string; dataView: IMLDataView; pipeline: IMLEstimatorChain<IMLTransformer>; numberOfRows: Integer = 4);
procedure ConsoleWriteHeader(lines: TArray<string>);
procedure ConsoleWriterSection(lines: TArray<string>);
procedure ConsolePressAnyKey();
procedure ConsoleWriteException(lines: TArray<string>);
procedure ConsoleWriteWarning(lines: TArray<string>);
function GetAbsolutePath(relativePath: string): string;
procedure EvaluateMetrics(const mlContext: IMLContextManager; predictions: IMLDataView);
function Join(const Separator: string; Values: TArray<Single>): string;
function Take(Values: IReadOnlySpan<Single>; Number: Integer): TArray<Single>;



implementation

uses CNCoreClrLib.RttiMgr, CNCoreClrLib.ObjectMgr, CNCoreClrLib.ArrayMgr, Rtti, CrystalNet.IO.FileSystem;

function Join(const Separator: string; Values: TArray<Single>): string;
var
  I: Integer;
  len: Integer;
begin
  len := System.Length(Values);
  if len = 0 then
    Result := ''
  else begin
    Result := FloatToStr(Values[0]);
    for I := 1 to len-1 do
      Result := Result + Separator + FloatToStr(Values[I]);
  end;
end;

function Take(Values: IReadOnlySpan<Single>; Number: Integer): TArray<Single>;
var
  I: Integer;
begin
  if Number > Values.Length then
    Number := Values.Length;

  for I := 0 to Number - 1 do
  begin
    Result := Result + [Values.Item[I]];
  end;
end;

function GetAbsolutePath(relativePath: string): string;
begin
  var _dataRoot := TFileInfo.Create(ParamStr(0));
  var assemblyFolderPath := _dataRoot.Directory.FullName;

  var fullPath := TPath.NClass.Combine(assemblyFolderPath, relativePath);

  Result := TPath.NClass.GetFullPath(fullPath);
end;


//function Average(Values: TArray<Double>): Double;
//var
//  m_value: Double;
//begin
//  var sumValues := 0.0;
//  for m_value in Values do
//  begin
//    sumValues := sumValues + m_value;
//  end;
//
//  Result:= sumValues / Length(Values);
//end;

procedure PrintPrediction(prediction: string);
begin
  TConsole.NClass.WriteLine('*************************************************');
  TConsole.NClass.WriteLine('Predicted : {0}', prediction);
  TConsole.NClass.WriteLine('*************************************************');
end;

procedure PrintRegressionPredictionVersusObserved(predictionCount, observedCount: string);
begin
  TConsole.NClass.WriteLine('-------------------------------------------------');
  TConsole.NClass.WriteLine('Predicted : {0}', predictionCount);
  TConsole.NClass.WriteLine('Actual:     {0}', observedCount);
  TConsole.NClass.WriteLine('-------------------------------------------------');
end;

procedure PrintRegressionMetrics(name: string; metrics: IMLRegressionMetrics);
begin
  TConsole.NClass.WriteLine('*************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {name} regression model      ');
  TConsole.NClass.WriteLine('*------------------------------------------------');
  TConsole.NClass.WriteLine('*       LossFn:        {0:0.##}', metrics.LossFunction);
  TConsole.NClass.WriteLine('*       R2 Score:      {0:0.##}', metrics.RSquared);
  TConsole.NClass.WriteLine('*       Absolute loss: {0:#.##}', metrics.MeanAbsoluteError);
  TConsole.NClass.WriteLine('*       Squared loss:  {0:#.##}', metrics.MeanSquaredError);
  TConsole.NClass.WriteLine('*       RMS loss:      {0:#.##}', metrics.RootMeanSquaredError);
  TConsole.NClass.WriteLine('*************************************************');
end;

procedure PrintBinaryClassificationMetrics(name: string; metrics: ICalibratedBinaryClassificationMetrics);
begin
  TConsole.NClass.WriteLine('************************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {0} binary classification model      ', name);
  TConsole.NClass.WriteLine('*-----------------------------------------------------------');
  TConsole.NClass.WriteLine('*       Accuracy: {0:P2}', metrics.Accuracy);
  TConsole.NClass.WriteLine('*       Area Under Curve:      {0:P2}', metrics.AreaUnderRocCurve);
  TConsole.NClass.WriteLine('*       Area under Precision recall Curve:  {0:P2}', metrics.AreaUnderPrecisionRecallCurve);
  TConsole.NClass.WriteLine('*       F1Score:  {0:P2}', metrics.F1Score);
  TConsole.NClass.WriteLine('*       LogLoss:  {0:#.##}', metrics.LogLoss);
  TConsole.NClass.WriteLine('*       LogLossReduction:  {0:#.##}', metrics.LogLossReduction);
  TConsole.NClass.WriteLine('*       PositivePrecision:  {0:#.##}', metrics.PositivePrecision);
  TConsole.NClass.WriteLine('*       PositiveRecall:  {0:#.##}', metrics.PositiveRecall);
  TConsole.NClass.WriteLine('*       NegativePrecision:  {0:#.##}', metrics.NegativePrecision);
  TConsole.NClass.WriteLine('*       NegativeRecall:  {0:P2}', metrics.NegativeRecall);
  TConsole.NClass.WriteLine('************************************************************');
end;

procedure PrintAnomalyDetectionMetrics(name: string; metrics: IAnomalyDetectionMetrics);
begin
  TConsole.NClass.WriteLine('************************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {name} anomaly detection model      ');
  TConsole.NClass.WriteLine('*-----------------------------------------------------------');
  TConsole.NClass.WriteLine('*       Area Under ROC Curve:                       {0:P2}', metrics.AreaUnderRocCurve);
  TConsole.NClass.WriteLine('*       Detection rate at false positive count: {0}', metrics.DetectionRateAtFalsePositiveCount);
  TConsole.NClass.WriteLine('************************************************************');
end;

procedure PrintMultiClassClassificationMetrics(name: string; metrics: IMLMulticlassClassificationMetrics);
begin
  TConsole.NClass.WriteLine('************************************************************');
  TConsole.NClass.WriteLine('*    Metrics for {name} multi-class classification model   ');
  TConsole.NClass.WriteLine('*-----------------------------------------------------------');
  TConsole.NClass.WriteLine('    AccuracyMacro = {0:0.####}, a value between 0 and 1, the closer to 1, the better', metrics.MacroAccuracy);
  TConsole.NClass.WriteLine('    AccuracyMicro = {0:0.####}, a value between 0 and 1, the closer to 1, the better', metrics.MicroAccuracy);
  TConsole.NClass.WriteLine('    LogLoss = {0:0.####}, the closer to 0, the better', metrics.LogLoss);
  TConsole.NClass.WriteLine('    LogLoss for class 1 = {0:0.####}, the closer to 0, the better', metrics.PerClassLogLoss[0]);
  TConsole.NClass.WriteLine('    LogLoss for class 2 = {0:0.####}, the closer to 0, the better', metrics.PerClassLogLoss[1]);
  TConsole.NClass.WriteLine('    LogLoss for class 3 = {0:0.####}, the closer to 0, the better', metrics.PerClassLogLoss[2]);
  TConsole.NClass.WriteLine('************************************************************');
end;

procedure PrintRegressionFoldsAverageMetrics(algorithmName: string; crossValidationResults: Enumerable<IMLCrossValidationResult<IMLRegressionMetrics>>);
begin
  var L1 := crossValidationResults.Select<Double>(function(Value: IMLCrossValidationResult<IMLRegressionMetrics>): Double
                                                    begin
                                                      Result := Value.Metrics.MeanAbsoluteError;
                                                    end);

  var L2 := crossValidationResults.Select<Double>(function(Value: IMLCrossValidationResult<IMLRegressionMetrics>): Double
                                                    begin
                                                      Result := Value.Metrics.MeanSquaredError;
                                                    end);

  var RMS := crossValidationResults.Select<Double>(function(Value: IMLCrossValidationResult<IMLRegressionMetrics>): Double
                                                     begin
                                                       Result := Value.Metrics.RootMeanSquaredError;
                                                     end);

  var lossFunction := crossValidationResults.Select<Double>(function(Value: IMLCrossValidationResult<IMLRegressionMetrics>): Double
                                                              begin
                                                                Result := Value.Metrics.LossFunction;
                                                              end);

  var R2 := crossValidationResults.Select<Double>(function(Value: IMLCrossValidationResult<IMLRegressionMetrics>): Double
                                                    begin
                                                      Result := Value.Metrics.RSquared;
                                                    end);

  TConsole.NClass.WriteLine('*************************************************************************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {0} Regression model      ', algorithmName);
  TConsole.NClass.WriteLine('*------------------------------------------------------------------------------------------------------------');
  TConsole.NClass.WriteLine('*       Average L1 Loss:    {0:0.###} ', L1.Average());
  TConsole.NClass.WriteLine('*       Average L2 Loss:    {0:0.###}  ', L2.Average());
  TConsole.NClass.WriteLine('*       Average RMS:          {0:0.###}  ', RMS.Average());
  TConsole.NClass.WriteLine('*       Average Loss Function: {0:0.###}  ', lossFunction.Average());
  TConsole.NClass.WriteLine('*       Average R-squared: {0:0.###}  ', R2.Average());
  TConsole.NClass.WriteLine('*************************************************************************************************************');
end;

procedure PrintMulticlassClassificationFoldsAverageMetrics(algorithmName: string; crossValResults: Enumerable<IMLCrossValidationResult<IMLMulticlassClassificationMetrics>>);
begin
  var metricsInMultipleFolds := crossValResults.Select<IMLMulticlassClassificationMetrics>(function(Value: IMLCrossValidationResult<IMLMulticlassClassificationMetrics>): IMLMulticlassClassificationMetrics
                                                                                                    begin
                                                                                                      Result := Value.Metrics;
                                                                                                    end);

  var microAccuracyValues := metricsInMultipleFolds.Select<Double>(function(Value: IMLMulticlassClassificationMetrics): Double
                                                                   begin
                                                                     Result := Value.MicroAccuracy;
                                                                   end);

  var microAccuracyAverage := microAccuracyValues.Average();
  var microAccuraciesStdDeviation := CalculateStandardDeviation(microAccuracyValues);
  var microAccuraciesConfidenceInterval95 := CalculateConfidenceInterval95(microAccuracyValues);

  var macroAccuracyValues := metricsInMultipleFolds.Select<Double>(function(Value: IMLMulticlassClassificationMetrics): Double
                                                                   begin
                                                                     Result := Value.MacroAccuracy;
                                                                   end);
  var macroAccuracyAverage := macroAccuracyValues.Average();
  var macroAccuraciesStdDeviation := CalculateStandardDeviation(macroAccuracyValues);
  var macroAccuraciesConfidenceInterval95 := CalculateConfidenceInterval95(macroAccuracyValues);

  var logLossValues := metricsInMultipleFolds.Select<Double>(function(Value: IMLMulticlassClassificationMetrics): Double
                                                                   begin
                                                                     Result := Value.LogLoss;
                                                                   end);
  var logLossAverage := logLossValues.Average();
  var logLossStdDeviation := CalculateStandardDeviation(logLossValues);
  var logLossConfidenceInterval95 := CalculateConfidenceInterval95(logLossValues);

  var logLossReductionValues := metricsInMultipleFolds.Select<Double>(function(Value: IMLMulticlassClassificationMetrics): Double
                                                                   begin
                                                                     Result := Value.LogLossReduction;
                                                                   end);
  var logLossReductionAverage := logLossReductionValues.Average();
  var logLossReductionStdDeviation := CalculateStandardDeviation(logLossReductionValues);
  var logLossReductionConfidenceInterval95 := CalculateConfidenceInterval95(logLossReductionValues);

  TConsole.NClass.WriteLine('*************************************************************************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {algorithmName} Multi-class Classification model      ');
  TConsole.NClass.WriteLine('*------------------------------------------------------------------------------------------------------------');
  TConsole.NClass.WriteLine('*       Average MicroAccuracy:    {0:0.###}  - Standard deviation: ({1:#.###})  - Confidence Interval 95%: ({2:#.###})', microAccuracyAverage, microAccuraciesStdDeviation, microAccuraciesConfidenceInterval95);
  TConsole.NClass.WriteLine('*       Average MacroAccuracy:    {0:0.###}  - Standard deviation: ({1:#.###})  - Confidence Interval 95%: ({2:#.###})', macroAccuracyAverage, macroAccuraciesStdDeviation, macroAccuraciesConfidenceInterval95);
  TConsole.NClass.WriteLine('*       Average LogLoss:          {0:#.###}  - Standard deviation: ({1:#.###})  - Confidence Interval 95%: ({2:#.###})', logLossAverage, logLossStdDeviation, logLossConfidenceInterval95);
  TConsole.NClass.WriteLine('*       Average LogLossReduction: {0:#.###}  - Standard deviation: ({1:#.###})  - Confidence Interval 95%: ({2:#.###})', logLossReductionAverage, logLossReductionStdDeviation, logLossReductionConfidenceInterval95);
  TConsole.NClass.WriteLine('*************************************************************************************************************');
end;

//function CalculateStandardDeviation (values: TArray<double>): Double; overload;
//var
//  sumOfSquaresOfDifferences, value: Double;
//begin
//  var average := Average(values);
//  sumOfSquaresOfDifferences := 0;
//  for value in values do
//  begin
//    sumOfSquaresOfDifferences := sumOfSquaresOfDifferences + ((value - average) * (value - average));
//  end;
//
//  var standardDeviation := TMath.NClass.Sqrt(sumOfSquaresOfDifferences / (Length(values)-1));
//  Result := standardDeviation;
//end;

function CalculateStandardDeviation(values: Enumerable<Double>): Double;
var
  sumOfSquaresOfDifferences, value: Double;
begin
  var average := values.Average();
  sumOfSquaresOfDifferences := 0;
  for value in values do
  begin
    sumOfSquaresOfDifferences := sumOfSquaresOfDifferences + ((value - average) * (value - average));
  end;

  var standardDeviation := TMath.NClass.Sqrt(sumOfSquaresOfDifferences / (values.Count-1));
  Result := standardDeviation;
end;

//function CalculateConfidenceInterval95(values: TArray<double>): Double;
//begin
//  var confidenceInterval95 := 1.96 * CalculateStandardDeviation(values) / TMath.NClass.Sqrt((Length(values)-1));
//  Result := confidenceInterval95;
//end;

function CalculateConfidenceInterval95(values: Enumerable<double>): Double;
begin
  var confidenceInterval95 := 1.96 * CalculateStandardDeviation(values) / TMath.NClass.Sqrt((values.Count-1));
  Result := confidenceInterval95;
end;

procedure PrintClusteringMetrics(name: string; metrics: IClusteringMetrics);
begin
  TConsole.NClass.WriteLine('*************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {name} clustering model      ');
  TConsole.NClass.WriteLine('*------------------------------------------------');
  TConsole.NClass.WriteLine('*       Average Distance: {0}', metrics.AverageDistance);
  TConsole.NClass.WriteLine('*       Davies Bouldin Index is: {0}', metrics.DaviesBouldinIndex);
  TConsole.NClass.WriteLine('*************************************************');
end;

procedure ShowDataViewInConsole(const mlContext: IMLContextManager; dataView: IMLDataView; numberOfRows: Integer = 4);
//var
//  row: IRowInfo;
//  rowViewEnumerable: TCoreClrEnumerable<IRowInfo>;
//  columnEnumerable: TCoreClrEnumerable<IKeyValuePair<string, Variant>>;
//  column: IKeyValuePair<string, Variant>;
begin
//  var msg := TString.NClass.Format('Show data in DataView: Showing {0} rows with the columns', numberOfRows);
//  ConsoleWriteHeader([msg]);
//
//  var preViewTransformedData := TDebuggerExtensions.NClass.Preview(dataView, numberOfRows);
//  rowViewEnumerable := TCoreClrEnumerable<IRowInfo>.Create(preViewTransformedData.RowView);
//  try
//    for row in rowViewEnumerable do
//    begin
//      var ColumnCollection := row.Values;
//      var lineToPrint := 'Row--> ';
//      columnEnumerable := TCoreClrEnumerable<IKeyValuePair<string, Variant>>.Create(ColumnCollection);
//      try
//        for column in columnEnumerable do
//        begin
//          lineToPrint := lineToPrint + '| '+ column.Key + ':' + TObject.Wrap(column.Value).ToString;
//        end;
//        TConsole.NClass.WriteLine(lineToPrint + '\n');
//      finally
//        columnEnumerable.Free;
//      end;
//    end;
//  finally
//    rowViewEnumerable.Free;
//  end;
end;

// This method using 'DebuggerExtensions.Preview()' should only be used when debugging/developing, not for release/production trainings
procedure PeekDataViewInConsole(const mlContext: IMLContextManager; dataView: IMLDataView; pipeline: IMLEstimatorChain<IMLTransformer>; numberOfRows: Integer = 4);
var
  row: IMLRowInfo;
  column: IKeyValuePair<string, Variant>;
begin
  var msg := TString.NClass.Format('Peek data in DataView: Showing {0} rows with the columns', numberOfRows);
  ConsoleWriteHeader([msg]);

  //https://github.com/dotnet/machinelearning/blob/main/docs/code/MlNetCookBook.md#how-do-i-look-at-the-intermediate-data
  var transformer := pipeline.Fit(dataView);
  var transformedData := transformer.Transform(dataView);

  // 'transformedData' is a 'promise' of data, lazy-loading. call Preview
  //and iterate through the returned collection from preview.

  var preViewTransformedData := transformedData.Preview(numberOfRows);

  var rowViews := preViewTransformedData.RowView;

  for row in rowViews do
  begin
    var lineToPrint := 'Row--> ';
    for column in row.Values do
    begin
      lineToPrint := lineToPrint + '| '+ column.Key + ':' + TObject.Wrap(column.Value).ToString;
    end;
    TConsole.NClass.WriteLine(lineToPrint);
    TConsole.NClass.WriteLine();
  end;
end;

// This method using 'DebuggerExtensions.Preview()' should only be used when debugging/developing, not for release/production trainings
procedure PeekDataViewInConsole(const mlContext: IMLContextManager; dataView: IMLDataView; pipeline: IMLValueMappingEstimator; numberOfRows: Integer = 4);
var
  row: IMLRowInfo;
  column: IKeyValuePair<string, Variant>;
begin
  var msg := TString.NClass.Format('Peek data in DataView: Showing {0} rows with the columns', numberOfRows);
  ConsoleWriteHeader([msg]);

  //https://github.com/dotnet/machinelearning/blob/main/docs/code/MlNetCookBook.md#how-do-i-look-at-the-intermediate-data
  var transformer := pipeline.Fit(dataView);
  var transformedData := transformer.Transform(dataView);

  // 'transformedData' is a 'promise' of data, lazy-loading. call Preview
  //and iterate through the returned collection from preview.

  var preViewTransformedData := transformedData.Preview(numberOfRows);

  for row in preViewTransformedData.RowView do
  begin
    var lineToPrint := 'Row--> ';
    for column in row.Values do
    begin
      lineToPrint := lineToPrint + '| '+ column.Key + ':' + TObject.Wrap(column.Value).ToString;
    end;
    TConsole.NClass.WriteLine(lineToPrint);
    TConsole.NClass.WriteLine();
  end;
end;

// This method using 'DebuggerExtensions.Preview()' should only be used when debugging/developing, not for release/production trainings
procedure PeekVectorColumnDataInConsole(const mlContext: IMLContextManager; columnName: string; dataView: IMLDataView; pipeline: IMLEstimatorChain<IMLTransformer>; numberOfRows: Integer = 4);
var
  row: Variant;
  rowMsg: string;
  f: Single;
begin
  var msg := TString.NClass.Format('Peek data in DataView: : Show {0} rows with just the ''{1}'' column', numberOfRows, columnName);
  ConsoleWriteHeader([msg]);

  var transformer := pipeline.Fit(dataView);
  var transformedData := transformer.Transform(dataView);

  // Extract the 'Features' column.
  var someColumnData := transformedData.GetColumn<TArray<Single>>(columnName).Take(numberOfRows);
//  var someColumnData := TMLEnumerableHelper.ConvertAll<Variant, TArray<Single>>(someColumnDataVariant);

  // print to TConsole.NClass the peeked rows

  var currentRow: Integer := 0;
  for row in someColumnData do
  begin
    Inc(currentRow);
    var concatColumn := '';
    //Create a Converter for ML
    var rowObject := TCoreClrObject.Create(row);
    var rows := TCoreClrGenericArray<Single>.Create(rowObject.DefaultPointer).ToArray;
    for f in rows do
      concatColumn := concatColumn + FloatToStr(f);

    TConsole.NClass.WriteLine();
    rowMsg := '**** Row ' + IntToStr(currentRow) + ' with '+ columnName +' field value ****';
    TConsole.NClass.WriteLine(rowMsg);
    TConsole.NClass.WriteLine(concatColumn);
    TConsole.NClass.WriteLine();
  end;
end;

procedure ConsoleWriteHeader(lines: TArray<string>);
var
  line: string;
  maxLength: Integer;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccYellow;
  TConsole.NClass.WriteLine(' ');

  maxLength := 0;
  for line in lines do
  begin
    TConsole.NClass.WriteLine(line);

    if Length(line) > maxLength then
      maxLength := Length(line);
  end;
  TConsole.NClass.WriteLine(TString.Create('#', maxLength));
  TConsole.NClass.ForegroundColor := defaultColor;
end;

procedure ConsoleWriterSection(lines: TArray<string>);
var
  line: string;
  maxLength: Integer;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccBlue;
  TConsole.NClass.WriteLine(' ');
  for line in lines do
  begin
    TConsole.NClass.WriteLine(line);

    if Length(line) > maxLength then
      maxLength := Length(line);
  end;
  TConsole.NClass.WriteLine(TString.Create('#', maxLength));
  TConsole.NClass.ForegroundColor := defaultColor;
end;

procedure ConsolePressAnyKey();
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccGreen;
  TConsole.NClass.WriteLine(' ');
  TConsole.NClass.WriteLine('Press any key to finish.');
  TConsole.NClass.ReadKey();
end;

procedure ConsoleWriteException(lines: TArray<string>);
const
  exceptionTitle = 'EXCEPTION';
var
  line: string;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccRed;
  TConsole.NClass.WriteLine(' ');
  TConsole.NClass.WriteLine(exceptionTitle);
  TConsole.NClass.WriteLine(TString.Create('#', Length(exceptionTitle)));
  TConsole.NClass.ForegroundColor := defaultColor;
  for line in lines do
  begin
    TConsole.NClass.WriteLine(line);
  end;
end;

procedure ConsoleWriteWarning(lines: TArray<string>);
const
  warningTitle = 'WARNING';
var
  line: string;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccDarkMagenta;
  TConsole.NClass.WriteLine(' ');
  TConsole.NClass.WriteLine(warningTitle);
  TConsole.NClass.WriteLine(TString.Create('#', Length(warningTitle)));
  TConsole.NClass.ForegroundColor := defaultColor;
  for line in lines do
  begin
    TConsole.NClass.WriteLine(line);
  end;
end;

// To evaluate the accuracy of the model's predicted rankings, prints out the Discounted Cumulative Gain and Normalized Discounted Cumulative Gain for search queries.
procedure EvaluateMetrics(const mlContext: IMLContextManager; predictions: IMLDataView);
begin
  // Evaluate the metrics for the data using NDCG; by default, metrics for the up to 3 search results in the query are reported (e.g. NDCG@3).
  var metrics := mlContext.Ranking.Evaluate(predictions);
//  TConsole.NClass.WriteLine('DCG: {string.Join(", ", metrics.DiscountedCumulativeGains.Select((d, i) => $"@{i + 1}:{d:F4}").ToArray())}');
//  TConsole.NClass.WriteLine('NDCG: {string.Join(", ", metrics.NormalizedDiscountedCumulativeGains.Select((d, i) => $"@{i + 1}:{d:F4}").ToArray())}');
//  TConsole.NClass.WriteLine;
end;

end.
