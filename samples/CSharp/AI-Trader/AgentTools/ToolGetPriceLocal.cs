using System;
using System.Threading.Tasks;
using AI_Trader.Models;
using AI_Trader.Tools;

namespace AI_Trader.AgentTools
{
    /// <summary>
    /// Tool for retrieving local price data
    /// </summary>
    public class ToolGetPriceLocal
    {
        private readonly string _dataDirectory;

        public ToolGetPriceLocal(string dataDirectory = "data")
        {
            _dataDirectory = dataDirectory;
        }

        public string Name => "get_price_local";

        public string Description => "Get historical price data for a stock symbol from local storage";

        /// <summary>
        /// Get price data for a symbol
        /// </summary>
        public async Task<ToolResult> GetPriceAsync(string symbol, DateTime? date = null)
        {
            try
            {
                var priceData = PriceTools.LoadPriceData(symbol, _dataDirectory);

                if (priceData.Count == 0)
                {
                    return new ToolResult
                    {
                        Success = false,
                        Error = $"No price data found for symbol: {symbol}"
                    };
                }

                if (date.HasValue)
                {
                    var specificPrice = PriceTools.GetPriceForDate(priceData, date.Value);
                    if (specificPrice == null)
                    {
                        return new ToolResult
                        {
                            Success = false,
                            Error = $"No price data found for {symbol} on {date.Value:yyyy-MM-dd}"
                        };
                    }

                    await Task.CompletedTask;
                    return new ToolResult
                    {
                        Success = true,
                        Data = specificPrice,
                        Message = $"Retrieved price for {symbol} on {date.Value:yyyy-MM-dd}"
                    };
                }

                await Task.CompletedTask;
                return new ToolResult
                {
                    Success = true,
                    Data = priceData,
                    Message = $"Retrieved {priceData.Count} price records for {symbol}"
                };
            }
            catch (Exception ex)
            {
                return new ToolResult
                {
                    Success = false,
                    Error = $"Failed to retrieve price data: {ex.Message}"
                };
            }
        }
    }
}
