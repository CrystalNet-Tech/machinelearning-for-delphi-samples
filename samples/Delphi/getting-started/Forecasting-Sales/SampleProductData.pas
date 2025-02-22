unit SampleProductData;

interface
uses ForecastingSales_Models;

type
  TSampleProductData = class
  private
    class var FMonthlyData: TArray<TProductData>;
  public
    class constructor Create;
    class property MonthlyData: TArray<TProductData> read FMonthlyData;
  end;


implementation

{ TSampleProductData }

class constructor TSampleProductData.Create;
begin
  var productData1 := TProductData.Create;
  with productData1 do
  begin
    productId := 988;
    month := 10;
    year := 2017;
    avg := 43;
    max := 220;
    min := 1;
    count := 25;
    prev := 1036;
    next := 1076;
    units := 1094;
  end;

  var productData2 := TProductData.Create;
  with productData2 do
  begin
    productId := 988;
    month := 11;
    year := 2017;
    avg := 41;
    max := 225;
    min := 4;
    count := 26;
    prev := 1094;
    units := 1076;
  end;

  FMonthlyData := [productData1, productData2];
end;

end.
