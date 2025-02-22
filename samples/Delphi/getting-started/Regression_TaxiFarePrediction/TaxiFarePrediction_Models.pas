unit TaxiFarePrediction_Models;

interface

uses MLAttributes, MLCore;

type
  TTaxiTrip = class(TMLEntity)
  public
    [LoadColumn(0)]
    VendorId: string;
    [LoadColumn(1)]
    RateCode: string;
    [LoadColumn(2)]
    PassengerCount: Single;
    [LoadColumn(3)]
    TripTime: Single;
    [LoadColumn(4)]
    TripDistance: Single;
    [LoadColumn(5)]
    PaymentType: string;
    [LoadColumn(6)]
    FareAmount: Single;
  end;

  TTaxiTripFarePrediction = class(TMLEntity)
  public
    [ColumnName('Score')]
    FareAmount: Single;
  end;

  TSingleTaxiTripSample = class
  public
    Trip1: TTaxiTrip;

    constructor Create;
  end;

implementation

{ TSingleTaxiTripSample }

constructor TSingleTaxiTripSample.Create;
begin
  Trip1 := TTaxiTrip.Create;
  with Trip1 do
  begin
    VendorId := 'VTS';
    RateCode := '1';
    PassengerCount := 1;
    TripDistance := 10.33;
    PaymentType := 'CSH';
    FareAmount := 0; // predict it. actual = 29.5
  end;
end;

end.
