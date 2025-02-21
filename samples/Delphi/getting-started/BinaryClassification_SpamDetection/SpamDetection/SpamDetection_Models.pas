unit SpamDetection_Models;

interface

uses MLAttributes, MLCore;

type
  TSpamInput = class(TMLEntity)
  private
    FLabel: string;
    FMessage: string;
  public
    [LoadColumn(0)]
    property &Label: string read FLabel write FLabel;
    [LoadColumn(1)]
    property Message: string read FMessage write FMessage;
  end;

  TSpamPrediction = class(TMLEntity)
  private
    FIsSpam: string;
  public
    [ColumnName('PredictedLabel')]
    property IsSpam: string read FIsSpam write FIsSpam;
  end;

implementation

end.
