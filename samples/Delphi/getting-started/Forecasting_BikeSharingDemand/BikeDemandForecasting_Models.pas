unit BikeDemandForecasting_Models;

interface

uses MLAttributes, MLCore;

type
  TModelInput = class(TMLEntity)
  public
    RentalDate: TDateTime;
    Year: Single;
    TotalRentals: Single;
  end;

  TModelOutput = class(TMLEntity)
  public
    ForecastedRentals: TArray<Double>;
    LowerBoundRentals: TArray<Double>;
    UpperBoundRentals: TArray<Double>;
  end;


implementation

end.
