unit ForecastingSales_Models;

interface

uses MLAttributes, MLCore;

type
  TProductData = class(TMLEntity)
  public
    // The index of column in LoadColumn(int index) should be matched with the position of columns in the underlying data file.
    // The next column is used by the Regression algorithm as the Label (e.g. the value that is being predicted by the Regression model).
    [LoadColumn(0)]
    next: Single;

    [LoadColumn(1)]
    productId: Single;

    [LoadColumn(2)]
    year: Single;

    [LoadColumn(3)]
    month: Single;

    [LoadColumn(4)]
    units: Single;

    [LoadColumn(5)]
    avg: Single;

    [LoadColumn(6)]
    count: Single;

    [LoadColumn(7)]
    max: Single;

    [LoadColumn(8)]
    min: Single;

    [LoadColumn(9)]
    prev: Single;

    function ToString: string; reintroduce;
  end;

  TProductUnitRegressionPrediction = class(TMLEntity)
  public
    // Below columns are produced by the model's predictor.
    Score: Single;
  end;

  /// <summary>
  /// This is the output of the scored time series model, the prediction.
  /// </summary>
  TProductUnitTimeSeriesPrediction = class(TMLEntity)
  private
    FForecastedProductUnits: TArray<Single>;
    FConfidenceLowerBound: TArray<Single>;
    FConfidenceUpperBound: TArray<Single>;
  public
    property ForecastedProductUnits: TArray<Single> read FForecastedProductUnits write FForecastedProductUnits;
    property ConfidenceLowerBound: TArray<Single> read FConfidenceLowerBound write FConfidenceLowerBound;
    property ConfidenceUpperBound: TArray<Single> read FConfidenceUpperBound write FConfidenceUpperBound;
  end;


implementation
uses CrystalNet.Runtime;

{ TProductData }

function TProductData.ToString: string;
begin
  Result := TString.NClass.Format('ProductData [ productId: {0}, year: {1}, month: {2:00}, next: {3:0000}, units: {4:0000}, avg: {5:000}, count: {6:00}, max: {7:000}, min: {8}, prev: {9:0000} ]',
    [productId, year, month, next, units, avg, count, max, min, prev]);
end;

end.
