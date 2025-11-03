using System;
using System.Threading.Tasks;
using AI_Trader.Models;

namespace AI_Trader.AgentTools
{
    /// <summary>
    /// Tool for performing mathematical calculations related to trading
    /// </summary>
    public class ToolMath
    {
        public string Name => "calculate";

        public string Description => "Perform financial calculations (portfolio value, returns, position sizing, etc.)";

        /// <summary>
        /// Calculate portfolio metrics
        /// </summary>
        public async Task<ToolResult> CalculatePortfolioMetricsAsync(Portfolio portfolio)
        {
            try
            {
                var metrics = new
                {
                    total_value = portfolio.TotalValue,
                    cash = portfolio.Cash,
                    positions_count = portfolio.Positions.Count,
                    total_return = portfolio.TotalReturn,
                    total_return_dollars = portfolio.TotalValue - portfolio.InitialCapital
                };

                await Task.CompletedTask;

                return new ToolResult
                {
                    Success = true,
                    Data = metrics,
                    Message = "Portfolio metrics calculated successfully"
                };
            }
            catch (Exception ex)
            {
                return new ToolResult
                {
                    Success = false,
                    Error = $"Calculation failed: {ex.Message}"
                };
            }
        }

        /// <summary>
        /// Calculate position size based on portfolio percentage
        /// </summary>
        public async Task<ToolResult> CalculatePositionSizeAsync(
            double portfolioValue,
            double targetPercentage,
            double stockPrice)
        {
            try
            {
                if (stockPrice <= 0)
                {
                    return new ToolResult
                    {
                        Success = false,
                        Error = "Stock price must be greater than 0"
                    };
                }

                var targetDollarAmount = portfolioValue * (targetPercentage / 100.0);
                var shares = (int)(targetDollarAmount / stockPrice);

                var result = new
                {
                    target_percentage = targetPercentage,
                    target_dollar_amount = targetDollarAmount,
                    shares = shares,
                    actual_dollar_amount = shares * stockPrice,
                    actual_percentage = (shares * stockPrice / portfolioValue) * 100
                };

                await Task.CompletedTask;

                return new ToolResult
                {
                    Success = true,
                    Data = result,
                    Message = $"Position size calculated: {shares} shares"
                };
            }
            catch (Exception ex)
            {
                return new ToolResult
                {
                    Success = false,
                    Error = $"Position size calculation failed: {ex.Message}"
                };
            }
        }

        /// <summary>
        /// Calculate risk metrics
        /// </summary>
        public async Task<ToolResult> CalculateRiskMetricsAsync(
            double entryPrice,
            double currentPrice,
            int quantity)
        {
            try
            {
                var unrealizedPnL = (currentPrice - entryPrice) * quantity;
                var unrealizedPnLPercent = ((currentPrice - entryPrice) / entryPrice) * 100;

                var metrics = new
                {
                    entry_price = entryPrice,
                    current_price = currentPrice,
                    quantity = quantity,
                    unrealized_pnl = unrealizedPnL,
                    unrealized_pnl_percent = unrealizedPnLPercent,
                    position_value = currentPrice * quantity
                };

                await Task.CompletedTask;

                return new ToolResult
                {
                    Success = true,
                    Data = metrics,
                    Message = "Risk metrics calculated successfully"
                };
            }
            catch (Exception ex)
            {
                return new ToolResult
                {
                    Success = false,
                    Error = $"Risk calculation failed: {ex.Message}"
                };
            }
        }
    }
}
