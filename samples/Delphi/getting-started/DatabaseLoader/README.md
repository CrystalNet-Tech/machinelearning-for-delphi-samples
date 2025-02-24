
# Sample using DatabaseLoader for training an ML model directly against data in a SQL Server database (Or any relational database)

![](https://devblogs.microsoft.com/dotnet/wp-content/uploads/sites/10/2019/08/database-loader-illustration-300x181.png)

This sample shows you how you can use the native database loader ro directly train an ML model against relational databases. This loader supports any relational database provider supported by System.Data in .NET Core or .NET Framework, meaning that you can use any RDBMS such as SQL Server, Azure SQL Database, Oracle, SQLite, PostgreSQL, MySQL, Progress, IBM DB2, etc.

## Problem

In the enterprise and many organizations in general, data is organized and stored as relational databases to be used by enterprise applications. Many of those organizations also prepare their ML model training/evaluation data in relational databases which is also where the new data is being collected and prepared. Therefore, many of those users would also like to directly train/evaluate ML models directly agaist that data stored in relational databases.

## Solution

This new Database Loader provides a much simpler code implementation for you since the way it reads from the database and makes data available through the IMLDataView is provided by the [ML.Net for Delphi](https://crystalnet-tech.com/Products/mldotNet4Delphi/Default) framework so you just need to specify your database connection string, what’s the SQL statement for the dataset columns and what’s the data-class to use when loading the data. It is that simple!

Here’s example code on how easily you can now configure your code to load data directly from a relational database into an IDataView which will be used later on when training your model.

```Delphi
const
  // Download the Criteo-100k-rows.md and Criteo-100k-rows_log.ldf from
  //  https://github.com/dotnet/machinelearning-samples/tree/main/samples/csharp/getting-started/DatabaseLoader/DatabaseLoaderConsoleApp/SqlLocalDb
  SqlLocalDb = '..\..\SqlLocalDb\Criteo-100k-rows.mdf';

[...]

var mlContext: IMLContextManager := TMLContextManager.Create();

// The following is a connection string using a localdb SQL database,
// but you can also use connection strings against on-premises SQL Server, Azure SQL Database
// or any other relational database (Oracle, SQLite, PostgreSQL, MySQL, Progress, IBM DB2, etc.)

// localdb SQL database connection string using a filepath to attach the database file into localdb
string dbFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SqlLocalDb", "Criteo-100k-rows.mdf");
var connectionString := 'Data Source = (LocalDB)\MSSQLLocalDB;AttachDbFilename='+ GetAbsolutePath(SqlLocalDb) +';Database=Criteo-100k-rows;Integrated Security = True';

var commandText := 'SELECT * from URLClicks';

var loader: IMLDatabaseLoader := mlContext.Data.CreateDatabaseLoader<TUrlClick>();

var dbSource := TMLDatabaseSource.Create(TSqlClientFactory.NClass.Instance, connectionString, commandText);

var dataView: IMLDataView := loader.Load(dbSource);

// From this point you can use the IMLDataView for training and validating an ML.NET model as in any other sample
```

Check the rest of the sample training and evaluating an ML.NET model in the **program.cs** file.

