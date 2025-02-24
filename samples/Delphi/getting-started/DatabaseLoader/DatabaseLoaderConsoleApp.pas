unit DatabaseLoaderConsoleApp;

interface
type
  TDatabaseLoaderConsoleApp = class
  private
  public
    class procedure Run;
    class function Sigmoid(x: Single): Single;
    class procedure DetachDatabase(userConnectionString: string);
  end;

implementation

uses DatabaseLoader_Models, MLContextMgr, System.Data.SqlClient, System.Data.SqlClient.Intf, MLData, MLTransforms, CrystalNet.Console,
  Crystalnet.Runtime, ConsoleHelper, CrystalNet.Drawing.Primitives, CrystalNet.Data.Common.Enums;

const
  // Download the Criteo-100k-rows.md and Criteo-100k-rows_log.ldf from
  //  https://github.com/dotnet/machinelearning-samples/tree/main/samples/csharp/getting-started/DatabaseLoader/DatabaseLoaderConsoleApp/SqlLocalDb
  SqlLocalDb = '..\..\SqlLocalDb\Criteo-100k-rows.mdf';


{ TDatabaseLoaderConsoleApp }

class procedure TDatabaseLoaderConsoleApp.Run;
begin
  var mlContext: IMLContextManager := TMLContextManager.Create();

  // localdb SQL database connection string using a filepath to attach the database file into localdb
  var connectionString := 'Data Source = (LocalDB)\MSSQLLocalDB;AttachDbFilename='+ SqlLocalDb +';Database=Criteo-100k-rows;Integrated Security = True';

  // ConnString Example: localdb SQL database connection string for 'localdb default location' (usually files located at /Users/YourUser/)
  //string connectionString = @'Data Source=(localdb)\MSSQLLocalDb;Initial Catalog=YOUR_DATABASE;Integrated Security=True;Pooling=False';
  //
  // ConnString Example: on-premises SQL Server Database (Integrated security)
  //string connectionString = @'Data Source=YOUR_SERVER;Initial Catalog=YOUR_DATABASE;Integrated Security=True;Pooling=False';
  //
  // ConnString Example:  Azure SQL Database connection string
  //string connectionString = @'Server=tcp:yourserver.database.windows.net,1433; Initial Catalog = YOUR_DATABASE; Persist Security Info = False; User ID = YOUR_USER; Password = YOUR_PASSWORD; MultipleActiveResultSets = False; Encrypt = True; TrustServerCertificate = False; Connection Timeout = 60; ConnectRetryCount = 5; ConnectRetryInterval = 10;';

  var commandText := 'SELECT * from URLClicks';

  var loader := mlContext.Data.CreateDatabaseLoader<TUrlClick>();

  var dbSource := TMLDatabaseSource.Create(TSqlClientFactory.NClass.Instance, connectionString, commandText);

  var dataView := loader.Load(dbSource);

  var trainTestData := mlContext.Data.TrainTestSplit(dataView);

  //do the transformation in IDataView
  //Transform categorical features into binary
  var CatogoriesTranformer := mlContext.Transforms.Conversion.ConvertType('Label', '', TMLDataKind.dkBoolean).
      Append(mlContext.Transforms.Categorical.OneHotEncoding([
      TMLInputOutputColumnPair.Create('Cat14Encoded', 'Cat14'),
      TMLInputOutputColumnPair.Create('Cat15Encoded', 'Cat15'),
      TMLInputOutputColumnPair.Create('Cat16Encoded', 'Cat16'),
      TMLInputOutputColumnPair.Create('Cat17Encoded', 'Cat17'),
      TMLInputOutputColumnPair.Create('Cat18Encoded', 'Cat18'),
      TMLInputOutputColumnPair.Create('Cat19Encoded', 'Cat19'),
      TMLInputOutputColumnPair.Create('Cat20Encoded', 'Cat20'),
      TMLInputOutputColumnPair.Create('Cat21Encoded', 'Cat21'),
      TMLInputOutputColumnPair.Create('Cat22Encoded', 'Cat22'),
      TMLInputOutputColumnPair.Create('Cat23Encoded', 'Cat23'),
      TMLInputOutputColumnPair.Create('Cat24Encoded', 'Cat24'),
      TMLInputOutputColumnPair.Create('Cat25Encoded', 'Cat25'),
      TMLInputOutputColumnPair.Create('Cat26Encoded', 'Cat26'),
      TMLInputOutputColumnPair.Create('Cat27Encoded', 'Cat27'),
      TMLInputOutputColumnPair.Create('Cat28Encoded', 'Cat28'),
      TMLInputOutputColumnPair.Create('Cat29Encoded', 'Cat29'),
      TMLInputOutputColumnPair.Create('Cat30Encoded', 'Cat30'),
      TMLInputOutputColumnPair.Create('Cat31Encoded', 'Cat31'),
      TMLInputOutputColumnPair.Create('Cat32Encoded', 'Cat32'),
      TMLInputOutputColumnPair.Create('Cat33Encoded', 'Cat33'),
      TMLInputOutputColumnPair.Create('Cat34Encoded', 'Cat34'),
      TMLInputOutputColumnPair.Create('Cat35Encoded', 'Cat35'),
      TMLInputOutputColumnPair.Create('Cat36Encoded', 'Cat36'),
      TMLInputOutputColumnPair.Create('Cat37Encoded', 'Cat37'),
      TMLInputOutputColumnPair.Create('Cat38Encoded', 'Cat38'),
      TMLInputOutputColumnPair.Create('Cat39Encoded', 'Cat39')],
    TMLOutputKind.okBinary));

  var featuresTransformer := CatogoriesTranformer.Append(
      mlContext.Transforms.Text.FeaturizeText('Feat01Featurized', 'Feat01'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat02Featurized', 'Feat02'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat03Featurized', 'Feat03'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat04Featurized', 'Feat04'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat05Featurized', 'Feat05'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat06Featurized', 'Feat06'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat07Featurized', 'Feat07'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat08Featurized', 'Feat08'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat09Featurized', 'Feat09'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat10Featurized', 'Feat10'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat11Featurized', 'Feat11'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat12Featurized', 'Feat12'))
      .Append(mlContext.Transforms.Text.FeaturizeText('Feat13Featurized', 'Feat13'));

  var finalTransformerPipeLine := featuresTransformer.Append(mlContext.Transforms.Concatenate('Features',
                  ['Feat01Featurized', 'Feat02Featurized', 'Feat03Featurized', 'Feat04Featurized', 'Feat05Featurized',
                  'Feat06Featurized', 'Feat07Featurized', 'Feat08Featurized', 'Feat09Featurized', 'Feat10Featurized',
                  'Feat11Featurized', 'Feat12Featurized', 'Feat12Featurized',
                  'Cat14Encoded', 'Cat15Encoded', 'Cat16Encoded', 'Cat17Encoded', 'Cat18Encoded', 'Cat19Encoded',
                  'Cat20Encoded', 'Cat21Encoded', 'Cat22Encoded', 'Cat23Encoded', 'Cat24Encoded', 'Cat25Encoded',
                  'Cat26Encoded', 'Cat27Encoded', 'Cat28Encoded', 'Cat29Encoded', 'Cat30Encoded', 'Cat31Encoded',
                  'Cat32Encoded', 'Cat33Encoded', 'Cat34Encoded', 'Cat35Encoded', 'Cat36Encoded', 'Cat37Encoded',
                  'Cat38Encoded', 'Cat39Encoded']));

	// Apply the ML algorithm
  var trainingPipeLine := finalTransformerPipeLine.Append(mlContext.BinaryClassification.Trainers.FieldAwareFactorizationMachine('Features', 'Label'));

  TConsole.NClass.WriteLine('Training the ML model while streaming data from a SQL database...');
  var watch := TStopwatch.Create();
  watch.Start();

  var model := trainingPipeLine.Fit(trainTestData.TrainSet);

  watch.Stop();
  TConsole.NClass.WriteLine('Elapsed time for training the model = {0} seconds', watch.ElapsedMilliseconds/1000);

  TConsole.NClass.WriteLine('Evaluating the model...');
  var watch2 := TStopwatch.Create();
  watch2.Start();

  var predictions := model.Transform(trainTestData.TestSet);
  // Now that we have the test predictions, calculate the metrics of those predictions and output the results.
  var metrics := mlContext.BinaryClassification.Evaluate(predictions);

  watch2.Stop();
  TConsole.NClass.WriteLine('Elapsed time for evaluating the model = {0} seconds', watch2.ElapsedMilliseconds / 1000);

  ConsoleHelper.PrintBinaryClassificationMetrics('==== Evaluation Metrics training from a Database ====', metrics);

  //
  TConsole.NClass.WriteLine('Trying a single prediction:');

  var predictionEngine := mlContext.Model.CreatePredictionEngine<TUrlClick, TClickPrediction>(model);

  var sampleData := TUrlClick.Create();
  with sampleData do
  begin
    &Label := '';
    Feat01 := '32'; Feat02 := '3'; Feat03 := '5'; Feat04 := 'NULL'; Feat05 := '1';
    Feat06 := '0'; Feat07 := '0'; Feat08 := '61'; Feat09 := '5'; Feat10 := '0';
    Feat11 := '1'; Feat12 := '3157'; Feat13 := '5';
    Cat14 := 'e5f3fd8d'; Cat15 := 'a0aaffa6'; Cat16 := 'aa15d56f'; Cat17 := 'da8a3421';
    Cat18 := 'cd69f233'; Cat19 := '6fcd6dcb'; Cat20 := 'ab16ed81'; Cat21 := '43426c29';
    Cat22 := '1df5e154'; Cat23 := '00c5ffb7'; Cat24 := 'be4ee537'; Cat25 := 'f3bbfe99';
    Cat26 := '7de9c0a9'; Cat27 := '6652dc64'; Cat28 := '99eb4e27'; Cat29 := '4cdc3efa';
    Cat30 := 'd20856aa'; Cat31 := 'a1eb1511'; Cat32 := '9512c20b'; Cat33 := 'febfd863';
    Cat34 := 'a3323ca1'; Cat35 := 'c8e1ee56'; Cat36 := '1752e9e8'; Cat37 := '75350c8a';
    Cat38 := '991321ea'; Cat39 := 'b757e957'
  end;

  var clickPrediction := predictionEngine.Predict(sampleData);

  TConsole.NClass.WriteLine('Predicted Label: {0} - Score:{1}', [clickPrediction.PredictedLabel, Sigmoid(clickPrediction.Score)]);//TColor.NClass.YellowGreen);
  TConsole.NClass.WriteLine();

  //*** Detach database from localdb only if you used a conn-string with a filepath to attach the database file into localdb ***
  TConsole.NClass.WriteLine('... Detaching database from SQL localdb ...');
  DetachDatabase(connectionString);

  TConsole.NClass.WriteLine('=============== Press any key ===============');
  TConsole.NClass.ReadKey();
end;

class procedure TDatabaseLoaderConsoleApp.DetachDatabase(
  userConnectionString: string);
begin
  var dbName := '';
  var userSqlDatabaseConnection := TSqlConnection.Create(userConnectionString);
  try
    userSqlDatabaseConnection.Open();
    dbName := userSqlDatabaseConnection.Database;
  finally
    userSqlDatabaseConnection.Dispose;
    userSqlDatabaseConnection := nil;
  end;

  var masterConnString := 'Data Source = (LocalDB)\MSSQLLocalDB;Integrated Security = True';
  var sqlDatabaseConnection := TSqlConnection.Create(masterConnString);
  try
      sqlDatabaseConnection.Open();

      var prepareDbcommandString := TString.NClass.Format('ALTER DATABASE [{0}] SET OFFLINE WITH ROLLBACK IMMEDIATE ALTER DATABASE [{0}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE', dbName);
      //(ALTERNATIVE) string prepareDbcommandString = $'ALTER DATABASE [{dbName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE';
      var sqlPrepareCommand := TSqlCommand.Create(prepareDbcommandString, sqlDatabaseConnection);
      sqlPrepareCommand.ExecuteNonQuery();

      var detachCommandString := 'sp_detach_db';
      var sqlDetachCommand := TSqlCommand.Create(detachCommandString, sqlDatabaseConnection);
      sqlDetachCommand.CommandType := TCommandType.ctStoredProcedure;
      sqlDetachCommand.Parameters.AddWithValue('@dbname', dbName);
      sqlDetachCommand.ExecuteNonQuery();
  finally
    sqlDatabaseConnection.Dispose;
    sqlDatabaseConnection := nil;
  end;
end;

class function TDatabaseLoaderConsoleApp.Sigmoid(x: Single): Single;
begin
 Result := (100 / (1 + TMath.NClass.Exp(-x)));
end;

end.
