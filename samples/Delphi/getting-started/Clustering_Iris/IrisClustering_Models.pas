unit IrisClustering_Models;

interface
uses MLAttributes, MLCore;

type
  TIrisData = class(TMLEntity)
  public
    [LoadColumn(0)]
    &Label: Single;

    [LoadColumn(1)]
    SepalLength: Single;

    [LoadColumn(2)]
    SepalWidth: Single;

    [LoadColumn(3)]
    PetalLength: Single;

    [LoadColumn(4)]
    PetalWidth: Single;
  end;

   // IrisPrediction is the result returned from prediction operations
  TIrisPrediction = class(TMLEntity)
  public
    [ColumnName('PredictedLabel')]
    SelectedClusterId: UInt32;

    [ColumnName('Score')]
    Score: TArray<Single>;
  end;



implementation

end.
