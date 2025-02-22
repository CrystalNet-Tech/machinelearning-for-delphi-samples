unit LargeDatasets_Models;

interface
uses MLCore, MLAttributes;

type

  TUrlData = class(TMLEntity)
  public
    [LoadColumn(0)]
    LabelColumn: string;

    [LoadColumn(1, 3231961)]
    [VectorType(3231961)]
    FeatureVector: TArray<Single>;
  end;

  TUrlPrediction = class(TMLEntity)
  public
    // ColumnName attribute is used to change the column name from
    // its default value, which is the name of the field.
    [ColumnName('PredictedLabel')]
    Prediction: Boolean;

    Score: Single;
  end;

implementation

end.
