unit ImageClassification_Models;

interface

uses MLAttributes, MLCore;

type
  TImagePrediction = class(TMLEntity)
  public
    [ColumnName('Score')]
    Score: TArray<Single>;

    [ColumnName('PredictedLabel')]
    PredictedLabel: string;
  end;

  TInMemoryImageData = class(TMLEntity)
  private
    FImage: TArray<byte>;
    FLabel: string;
    FImageFileName: string;
  public
    Constructor Create(Image: TArray<byte>; &Label: string; ImageFileName: string);

    property Image: TArray<byte> read FImage write FImage;
    property &Label: string read FLabel write FLabel;
    property ImageFileName: string read FImageFileName write FImageFileName;
  end;

  TImageData = class(TMLEntity)
  private
    FLabel: string;
    FImagePath: string;
  public
    Constructor Create(imagePath: string; &Label: string);

    property &Label: string read FLabel write FLabel;
    property ImagePath: string read FImagePath write FImagePath;
  end;


implementation

{ TInMemoryImageData }

constructor TInMemoryImageData.Create(Image: TArray<byte>; &Label,
  ImageFileName: string);
begin
  FImage := Image;
  FLabel := &Label;
  FImageFileName := ImageFileName;
end;

{ TImageData }

constructor TImageData.Create(imagePath, &Label: string);
begin
  FImagePath := imagePath;
  FLabel := &Label;
end;

end.
