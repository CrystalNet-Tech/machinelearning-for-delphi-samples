using System;
using System.Threading.Tasks;
using AI_Trader.Models;

namespace AI_Trader.AgentTools
{
    /// <summary>
    /// Tool for executing trades
    /// </summary>
    public class ToolTrade
    {
        private readonly Action<string, int, double, string?> _buyCallback;
        private readonly Action<string, int, double, string?> _sellCallback;

        public ToolTrade(
            Action<string, int, double, string?> buyCallback,
            Action<string, int, double, string?> sellCallback)
        {
            _buyCallback = buyCallback ?? throw new ArgumentNullException(nameof(buyCallback));
            _sellCallback = sellCallback ?? throw new ArgumentNullException(nameof(sellCallback));
        }

        public string Name => "execute_trade";

        public string Description => "Execute a buy or sell trade for a stock symbol";

        /// <summary>
        /// Execute a trade
        /// </summary>
        public async Task<ToolResult> ExecuteAsync(
            string action,
            string symbol,
            int quantity,
            double price,
            string? reasoning = null)
        {
            try
            {
                if (action.ToLower() == "buy")
                {
                    _buyCallback(symbol, quantity, price, reasoning);
                }
                else if (action.ToLower() == "sell")
                {
                    _sellCallback(symbol, quantity, price, reasoning);
                }
                else
                {
                    return new ToolResult
                    {
                        Success = false,
                        Error = $"Invalid action: {action}. Must be 'buy' or 'sell'."
                    };
                }

                await Task.CompletedTask;

                return new ToolResult
                {
                    Success = true,
                    Message = $"Successfully executed {action} for {quantity} shares of {symbol} at ${price}"
                };
            }
            catch (Exception ex)
            {
                return new ToolResult
                {
                    Success = false,
                    Error = $"Trade execution failed: {ex.Message}"
                };
            }
        }
    }
}
