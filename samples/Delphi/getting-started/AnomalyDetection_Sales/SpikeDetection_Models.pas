unit SpikeDetection_Models;


interface

uses MLAttributes, MLCore;

type
  TProductSalesData = class(TMLEntity)
  public
    [LoadColumn(0)]
    Month: string;
    [LoadColumn(1)]
    numSales: Single;
  end;

  TProductSalesPrediction = class(TMLEntity)
  public
    // Vector to hold Alert, Score, and P-Value values
    [VectorType(3)]
    Prediction: TArray<Double>;
  end;


implementation


end.
