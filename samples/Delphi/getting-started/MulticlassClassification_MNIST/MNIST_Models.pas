unit MNIST_Models;

interface
uses MLAttributes, MLCore, System.Generics.Collections;

type

  TInputData = class(TMLEntity)
  public
    [ColumnName('PixelValues')]
    [VectorType(64)]
    PixelValues: TArray<Single>;

    [LoadColumn(64)]
    Number: Single;
  end;

 TTOutPutData = class(TMLEntity)
  public
    [ColumnName('Score')]
    Score: TArray<Single>;
 end;

 TSampleMNISTData = class
  private
    FMNIST1: TInputData;
    FMNIST2: TInputData;
    FMNIST3: TInputData;
  public
    constructor Create;
    destructor Destroy; override;
    property MNIST1: TInputData read FMNIST1;
    property MNIST2: TInputData read FMNIST2;
    property MNIST3: TInputData read FMNIST3;
  end;

var
  SampleMNISTData: TSampleMNISTData;


implementation


{ TSampleMNISTData }

constructor TSampleMNISTData.Create;
begin
  FMNIST1 := TInputData.Create;
  with FMNIST1 do
  begin
    PixelValues := [ 0, 0, 0, 0, 14, 13, 1, 0, 0, 0, 0, 5, 16, 16, 2, 0, 0, 0, 0, 14, 16, 12, 0, 0, 0, 1, 10, 16, 16, 12, 0, 0, 0, 3, 12, 14, 16, 9, 0, 0, 0, 0, 0, 5, 16, 15, 0, 0, 0, 0, 0, 4, 16, 14, 0, 0, 0, 0, 0, 1, 13, 16, 1, 0 ];
  end; //num 1

  FMNIST2 := TInputData.Create;
  with FMNIST2 do
  begin
    PixelValues := [ 0, 0, 1, 8, 15, 10, 0, 0, 0, 3, 13, 15, 14, 14, 0, 0, 0, 5, 10, 0, 10, 12, 0, 0, 0, 0, 3, 5, 15, 10, 2, 0, 0, 0, 16, 16, 16, 16, 12, 0, 0, 1, 8, 12, 14, 8, 3, 0, 0, 0, 0, 10, 13, 0, 0, 0, 0, 0, 0, 11, 9, 0, 0, 0 ];
  end;//num 7

  FMNIST3 := TInputData.Create;
  with FMNIST3 do
  begin
    PixelValues := [ 0, 0, 6, 14, 4, 0, 0, 0, 0, 0, 11, 16, 10, 0, 0, 0, 0, 0, 8, 14, 16, 2, 0, 0, 0, 0, 1, 12, 12, 11, 0, 0, 0, 0, 0, 0, 0, 11, 3, 0, 0, 0, 0, 0, 0, 5, 11, 0, 0, 0, 1, 4, 4, 7, 16, 2, 0, 0, 7, 16, 16, 13, 11, 1 ];
  end;// num9
end;

destructor TSampleMNISTData.Destroy;
begin
  FMNIST1.Free;
  FMNIST2.Free;
  FMNIST3.Free;
  inherited;
end;

initialization
  SampleMNISTData := TSampleMNISTData.Create;
finalization
  SampleMNISTData.Free;

end.
