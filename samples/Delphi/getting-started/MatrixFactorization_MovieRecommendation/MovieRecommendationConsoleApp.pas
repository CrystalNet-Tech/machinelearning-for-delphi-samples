unit MovieRecommendationConsoleApp;


interface

uses MovieRecommendation_Models, MLData, MLCore;

type
  TMovieRecommendationConsoleApp = class
  public
    class procedure Run;
  end;

implementation

uses MLContextMgr, MLOptions, CrystalNet.Console, CrystalNet.Runtime, ConsoleHelper;

const
  // Using the ml-latest-small.zip as dataset from https://grouplens.org/datasets/movielens/.
  DatasetsRelativePath = '..\..\Data';
  TrainingDataRelativePath = DatasetsRelativePath + '\recommendation-ratings-train.csv';
  TestDataRelativePath = DatasetsRelativePath + '\recommendation-ratings-test.csv';

  predictionuserId: Single = 6;
  predictionmovieId: Integer = 10;

{ TMovieRecommendationConsoleApp }

class procedure TMovieRecommendationConsoleApp.Run;
var
  TrainingDataLocation, TestDataLocation: string;
begin
  TrainingDataLocation := GetAbsolutePath(TrainingDataRelativePath);
  TestDataLocation := GetAbsolutePath(TestDataRelativePath);

  //STEP 1: Create MLContext to be shared across the model creation workflow objects
  var mlcontext: IMLContextManager := TMLContextManager.Create();

  //STEP 2: Read the training data which will be used to train the movie recommendation model
  //The schema for training data is defined by type 'TInput' in LoadFromTextFile<TInput>() method.
  var trainingDataView := mlcontext.Data.LoadFromTextFile<TMovieRating>(TrainingDataLocation, ',', True);

  //STEP 3: Transform your data by encoding the two features userId and movieID. These encoded features will be provided as input
  //        to our MatrixFactorizationTrainer.
  var dataProcessingPipeline := mlcontext.Transforms.Conversion.MapValueToKey('userIdEncoded', 'userId')
                                  .Append(mlcontext.Transforms.Conversion.MapValueToKey('movieIdEncoded', 'movieId'));

  //Specify the options for MatrixFactorization trainer
  var options := TMLMatrixFactorizationTrainerOptions.Create();
  options.MatrixColumnIndexColumnName := 'userIdEncoded';
  options.MatrixRowIndexColumnName := 'movieIdEncoded';
  options.LabelColumnName := 'Label';
  options.NumberOfIterations := 20;
  options.ApproximationRank := 100;

  //STEP 4: Create the training pipeline
  var trainingPipeLine := dataProcessingPipeline.Append(mlcontext.Recommendation().Trainers.MatrixFactorization(options));

  //STEP 5: Train the model fitting to the DataSet
  TConsole.NClass.WriteLine('=============== Training the model ===============');
  var model := trainingPipeLine.Fit(trainingDataView);

  //STEP 6: Evaluate the model performance
  TConsole.NClass.WriteLine('=============== Evaluating the model ===============');
  var testDataView := mlcontext.Data.LoadFromTextFile<TMovieRating>(TestDataLocation, ',', True);
  var prediction := model.Transform(testDataView);
  var metrics := mlcontext.Regression.Evaluate(prediction, 'Label', 'Score');
  TConsole.NClass.WriteLine('The model evaluation metrics RootMeanSquaredError: {0}', metrics.RootMeanSquaredError);

  //STEP 7:  Try/test a single prediction by predicting a single movie rating for a specific user
  var predictionengine := mlcontext.Model.CreatePredictionEngine<TMovieRating, TMovieRatingPrediction>(model);
  (* Make a single movie rating prediction, the scores are for a particular user and will range from 1 - 5.
     The higher the score the higher the likelyhood of a user liking a particular movie.
     You can recommend a movie to a user if say rating > 3.5.*)

  var MovieRating := TMovieRating.Create;
  //Example rating prediction for userId = 6, movieId = 10 (GoldenEye)
  MovieRating.userId := predictionuserId;
  MovieRating.movieId := predictionmovieId;

  var movieratingprediction := predictionengine.Predict(MovieRating);

  var movieService := TMovie.Create();
  TConsole.NClass.WriteLine('For userId:{0} movie rating prediction (1 - 5 stars) for movie:{1} is:{2}', predictionuserId, movieService.Get(predictionmovieId).movieTitle, TMath.NClass.Round(movieratingprediction.Score, 1));

  TConsole.NClass.WriteLine('=============== End of process, hit any key to finish ===============');
  TConsole.NClass.ReadLine();
end;

end.
