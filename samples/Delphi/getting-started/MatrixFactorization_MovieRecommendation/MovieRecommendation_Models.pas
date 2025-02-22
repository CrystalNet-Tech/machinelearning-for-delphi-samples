unit MovieRecommendation_Models;

interface

uses MLAttributes, MLCore, System.Generics.Collections;

type
  TMovieRating = class(TMLEntity)
  public
    [LoadColumn(0)]
    userId: Single;
    [LoadColumn(1)]
    movieId: Single;
    [LoadColumn(2)]
    &Label: Single;
  end;

  TMovieRatingPrediction = class(TMLEntity)
  public
    [LoadColumn(0)]
    &Label: Single;
    [LoadColumn(1)]
    Score: Single;
  end;

  TMovie = class
  public
    movieId: Integer;
    movieTitle: string;
    function Get(Id: Integer): TMovie;
  end;

implementation

uses CrystalNet.IO.FileSystem, CrystalNet.IO.FileSystem.Intf, CrystalNet.Runtime, CrystalNet.Runtime.Intf, SysUtils;

const
  moviesdatasetpath = 'C:\CrystalNet\CrystalNet Projects\Delphi Projects\dotNetCore4Delphi\AddOns\MLDotNet\Delphi\Projects\MLDotNetCore_Examples\MovieRecommendation\Data\recommendation-movies.csv';

var
  _movies: System.Generics.Collections.TList<TMovie>;

function LoadMovieData(Moviesdatasetpath: String): System.Generics.Collections.TList<TMovie>;
begin
  Result := System.Generics.Collections.TList<TMovie>.Create;
  var fileReader := TFile.NClass.OpenRead(moviesdatasetpath);
  var reader := TStreamReader.Create(fileReader);
  try
    var header: Boolean := True;
    var index: Integer := 0;
    var line: string := '';
    while (not reader.EndOfStream) do
    begin
      if header then
      begin
        line := reader.ReadLine();
        header := False;
      end;
      line := reader.ReadLine();
      var fields: TArray<string> := line.Split([',']);
      var fielsZero: IString := TString.Create(fields[0]);
      var movieId: Integer := TInt32.NClass.Parse(fielsZero.TrimStart(['0']));
      var movieTitle: string := fields[1];

      var movie := TMovie.Create;
      movie.movieId := movieId;
      movie.movieTitle := movieTitle;

      result.Add(movie);
      Inc(index);
    end;
  finally
    if reader <> nil then
      reader.Dispose();
  end;
end;

{ TMovie }

function TMovie.Get(Id: Integer): TMovie;
var
  m_movie: TMovie;
begin
  if _movies = nil then  _movies := LoadMovieData(moviesdatasetpath);

  for m_movie in _movies do
  begin
    if m_movie.movieId = Id then
      Exit(m_movie);
  end;

  Result := nil;
end;

initialization
finalization
  //Free Individual Objects in _movies.
  FreeAndNil(_movies);

end.
