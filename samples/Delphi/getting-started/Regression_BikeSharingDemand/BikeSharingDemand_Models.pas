unit BikeSharingDemand_Models;

interface

uses MLAttributes, MLCore;

type
  TDemandObservation = class(TMLEntity)
  public
    // Note that we're loading only some columns (certain indexes) starting on column number 2
    // Also, the label column is number 16.
    // Columns 14, 15 are not being loaded from the file.
    [LoadColumn(2)]
    Season: single;

    [LoadColumn(3)]
    Year: single;

    [LoadColumn(4)]
    Month: single;

    [LoadColumn(5)]
    Hour: single;

    [LoadColumn(6)]
    Holiday: single;

    [LoadColumn(7)]
    Weekday: single;

    [LoadColumn(8)]
    WorkingDay: single;

    [LoadColumn(9)]
    Weather: single;

    [LoadColumn(10)]
    Temperature: single;

    [LoadColumn(11)]
    NormalizedTemperature: single;

    [LoadColumn(12)]
    Humidity: single;

    [LoadColumn(13)]
    Windspeed: single;

    [LoadColumn(16)]
    [ColumnName('Label')]
    Count: single;   // This is the observed count, to be used a "label" to predict
  end;

  TDemandObservationSample = class
  private
    class function GetSingleDemandSampleData() : TDemandObservation; static;
  public
    class property SingleDemandSampleData: TDemandObservation read GetSingleDemandSampleData;
  end;

  TDemandPrediction = class(TMLEntity)
  public
    [ColumnName('Score')]
    PredictedCount: single;
  end;

implementation

{ TDemandObservationSample }

class function TDemandObservationSample.GetSingleDemandSampleData: TDemandObservation;
begin
  // Single data
  // instant,dteday,season,yr,mnth,hr,holiday,weekday,workingday,weathersit,temp,atemp,hum,windspeed,casual,registered,cnt
  // 13950,2012-08-09,3,1,8,10,0,4,1,1,0.8,0.7576,0.55,0.2239,72,133,205
  Result := TDemandObservation.Create;
  with Result do
  begin
    Season := 3;
    Year := 1;
    Month := 8;
    Hour := 10;
    Holiday := 0;
    Weekday := 4;
    WorkingDay := 1;
    Weather := 1;
    Temperature := 0.8;
    NormalizedTemperature := 0.7576;
    Humidity := 0.55;
    Windspeed := 0.2239
  end;
end;

end.
