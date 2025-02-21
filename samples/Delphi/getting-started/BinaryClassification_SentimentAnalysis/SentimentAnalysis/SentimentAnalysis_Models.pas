unit SentimentAnalysis_Models;

interface

uses MLAttributes, MLCore;

type
  TSentimentIssue = class(TMLEntity)
  public
    [LoadColumn(0)]
    &Label: Boolean;

    [LoadColumn(2)]
    Text: string;
  end;

  TSentimentPrediction = class(TMLEntity)
  public
    // ColumnName attribute is used to change the column name from
    // its default value, which is the name of the field.
    [ColumnName('PredictedLabel')]
    Prediction: Boolean;

    // No need to specify ColumnName attribute, because the field
    // name 'Probability' is the column name we want.
    Probability: Single;

    Score: Single;
  end;


implementation

end.
