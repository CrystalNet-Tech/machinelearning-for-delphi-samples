using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using AI_Trader.Models;

namespace AI_Trader.Tools
{
    /// <summary>
    /// Tools for managing and processing price data
    /// </summary>
    public static class PriceTools
    {
        /// <summary>
        /// Load historical price data from a JSON file
        /// </summary>
        public static List<PriceData> LoadPriceData(string symbol, string dataDirectory = "data")
        {
            var filename = $"daily_prices_{symbol}.json";
            var filepath = Path.Combine(dataDirectory, filename);

            if (!File.Exists(filepath))
            {
                Console.WriteLine($"⚠️  Price data file not found: {filepath}");
                return new List<PriceData>();
            }

            try
            {
                var json = File.ReadAllText(filepath);
                var data = JsonSerializer.Deserialize<List<PriceData>>(json);
                return data ?? new List<PriceData>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error loading price data for {symbol}: {ex.Message}");
                return new List<PriceData>();
            }
        }

        /// <summary>
        /// Get price for a specific date
        /// </summary>
        public static PriceData? GetPriceForDate(List<PriceData> priceData, DateTime date)
        {
            return priceData.FirstOrDefault(p => p.Date.Date == date.Date);
        }

        /// <summary>
        /// Get price range for a date range
        /// </summary>
        public static List<PriceData> GetPriceRange(List<PriceData> priceData, DateTime startDate, DateTime endDate)
        {
            return priceData
                .Where(p => p.Date.Date >= startDate.Date && p.Date.Date <= endDate.Date)
                .OrderBy(p => p.Date)
                .ToList();
        }

        /// <summary>
        /// Calculate simple moving average
        /// </summary>
        public static double? CalculateSMA(List<PriceData> priceData, int periods)
        {
            if (priceData.Count < periods)
                return null;

            var recentPrices = priceData.TakeLast(periods);
            return recentPrices.Average(p => p.Close);
        }

        /// <summary>
        /// Calculate price change percentage
        /// </summary>
        public static double CalculatePriceChange(double oldPrice, double newPrice)
        {
            if (oldPrice == 0)
                return 0;

            return ((newPrice - oldPrice) / oldPrice) * 100;
        }

        /// <summary>
        /// Add a no-trade record for tracking purposes
        /// </summary>
        public static void AddNoTradeRecord(DateTime date, string reason, string agentName)
        {
            // In a full implementation, this would log the no-trade decision
            Console.WriteLine($"   ℹ️  No trade on {date:yyyy-MM-dd}: {reason}");
        }

        /// <summary>
        /// Get latest available price before or on a given date
        /// </summary>
        public static PriceData? GetLatestPriceBeforeDate(List<PriceData> priceData, DateTime date)
        {
            return priceData
                .Where(p => p.Date.Date <= date.Date)
                .OrderByDescending(p => p.Date)
                .FirstOrDefault();
        }

        /// <summary>
        /// Calculate volatility (standard deviation of returns)
        /// </summary>
        public static double? CalculateVolatility(List<PriceData> priceData, int periods)
        {
            if (priceData.Count < periods + 1)
                return null;

            var recentPrices = priceData.TakeLast(periods + 1).ToList();
            var returns = new List<double>();

            for (int i = 1; i < recentPrices.Count; i++)
            {
                var dailyReturn = (recentPrices[i].Close - recentPrices[i - 1].Close) / recentPrices[i - 1].Close;
                returns.Add(dailyReturn);
            }

            if (returns.Count == 0)
                return null;

            var mean = returns.Average();
            var sumOfSquares = returns.Sum(r => Math.Pow(r - mean, 2));
            var variance = sumOfSquares / returns.Count;
            return Math.Sqrt(variance);
        }

        /// <summary>
        /// Validate price data integrity
        /// </summary>
        public static bool ValidatePriceData(PriceData data)
        {
            return data.Open > 0 && data.High > 0 && data.Low > 0 && data.Close > 0 &&
                   data.High >= data.Low &&
                   data.High >= data.Open &&
                   data.High >= data.Close &&
                   data.Low <= data.Open &&
                   data.Low <= data.Close;
        }
    }
}
