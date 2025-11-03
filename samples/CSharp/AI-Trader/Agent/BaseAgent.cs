using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AI_Trader.Models;
using AI_Trader.Tools;

namespace AI_Trader.Agent
{
    /// <summary>
    /// Base class for trading agents
    /// Encapsulates core functionality including AI model interaction, trading execution,
    /// and portfolio management
    /// </summary>
    public class BaseAgent : IAgent
    {
        protected readonly AgentConfig _config;
        protected Portfolio _portfolio;
        protected readonly List<TradeAction> _tradeHistory;
        protected DateTime _currentDate;

        // Default NASDAQ 100 stock symbols
        protected static readonly List<string> DEFAULT_STOCK_SYMBOLS = new()
        {
            "NVDA", "MSFT", "AAPL", "GOOG", "GOOGL", "AMZN", "META", "AVGO", 
            "TSLA", "NFLX", "PLTR", "COST", "ASML", "AMD", "CSCO", "AZN",
            "TMUS", "MU", "LIN", "PEP", "SHOP", "APP", "INTU", "AMAT",
            "LRCX", "PDD", "QCOM", "ARM", "INTC", "BKNG", "AMGN", "TXN"
        };

        public BaseAgent(AgentConfig config)
        {
            _config = config ?? throw new ArgumentNullException(nameof(config));
            _portfolio = new Portfolio
            {
                Cash = config.InitialCapital,
                InitialCapital = config.InitialCapital,
                Positions = new Dictionary<string, Position>()
            };
            _tradeHistory = new List<TradeAction>();
            _currentDate = config.StartDate;
        }

        /// <summary>
        /// Initialize the agent
        /// </summary>
        public virtual async Task InitializeAsync()
        {
            Console.WriteLine("🔧 Initializing BaseAgent...");
            Console.WriteLine($"   Agent Name: {_config.AgentName}");
            Console.WriteLine($"   Model: {_config.ModelName}");
            Console.WriteLine($"   Trading Period: {_config.StartDate:yyyy-MM-dd} to {_config.EndDate:yyyy-MM-dd}");
            Console.WriteLine($"   Initial Capital: ${_config.InitialCapital:N2}");
            Console.WriteLine($"   Stock Universe: {string.Join(", ", _config.StockSymbols.Take(5))}...");
            
            await Task.CompletedTask;
        }

        /// <summary>
        /// Run the trading session
        /// </summary>
        public virtual async Task RunAsync()
        {
            Console.WriteLine($"📅 Starting trading simulation from {_config.StartDate:yyyy-MM-dd} to {_config.EndDate:yyyy-MM-dd}");
            Console.WriteLine();

            var currentDate = _config.StartDate;
            var dayCount = 0;

            while (currentDate <= _config.EndDate)
            {
                // Skip weekends
                if (currentDate.DayOfWeek != DayOfWeek.Saturday && currentDate.DayOfWeek != DayOfWeek.Sunday)
                {
                    dayCount++;
                    _currentDate = currentDate;

                    Console.WriteLine($"📅 Trading Day {dayCount}: {currentDate:yyyy-MM-dd} ({currentDate:dddd})");
                    
                    try
                    {
                        await ProcessTradingDayAsync(currentDate);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"   ⚠️  Error processing day: {ex.Message}");
                    }

                    // Display portfolio status
                    DisplayPortfolioStatus();
                    Console.WriteLine();
                }

                currentDate = currentDate.AddDays(1);
            }

            // Final summary
            DisplayFinalSummary();
        }

        /// <summary>
        /// Process a single trading day
        /// </summary>
        protected virtual async Task ProcessTradingDayAsync(DateTime date)
        {
            // This is a simplified implementation
            // In a real implementation, this would:
            // 1. Fetch current market prices
            // 2. Get market news and intelligence
            // 3. Call AI model for trading decision
            // 4. Execute trades based on AI decision
            // 5. Update portfolio

            Console.WriteLine("   🤖 AI Agent analyzing market...");
            
            // Simulate AI decision-making delay
            await Task.Delay(100);

            // For demonstration, we'll just show that the agent is running
            Console.WriteLine("   ✅ Market analysis complete (simplified implementation)");
        }

        /// <summary>
        /// Display current portfolio status
        /// </summary>
        protected void DisplayPortfolioStatus()
        {
            Console.WriteLine($"   💰 Cash: ${_portfolio.Cash:N2}");
            Console.WriteLine($"   📊 Total Value: ${_portfolio.TotalValue:N2}");
            Console.WriteLine($"   📈 Return: {_portfolio.TotalReturn:+0.00;-0.00;0.00}%");
            
            if (_portfolio.Positions.Count > 0)
            {
                Console.WriteLine($"   🏦 Positions: {_portfolio.Positions.Count} stocks");
            }
        }

        /// <summary>
        /// Display final trading summary
        /// </summary>
        protected void DisplayFinalSummary()
        {
            Console.WriteLine("════════════════════════════════════════════════════");
            Console.WriteLine("📊 FINAL TRADING SUMMARY");
            Console.WriteLine("════════════════════════════════════════════════════");
            Console.WriteLine();
            Console.WriteLine($"Initial Capital:  ${_portfolio.InitialCapital:N2}");
            Console.WriteLine($"Final Value:      ${_portfolio.TotalValue:N2}");
            Console.WriteLine($"Total Return:     {_portfolio.TotalReturn:+0.00;-0.00;0.00}%");
            Console.WriteLine($"Total Trades:     {_tradeHistory.Count}");
            Console.WriteLine();

            if (_portfolio.Positions.Count > 0)
            {
                Console.WriteLine("Final Positions:");
                foreach (var (symbol, position) in _portfolio.Positions)
                {
                    Console.WriteLine($"  {symbol}: {position.Quantity} shares @ ${position.AveragePrice:N2} " +
                        $"(P/L: {position.UnrealizedPnLPercent:+0.00;-0.00;0.00}%)");
                }
                Console.WriteLine();
            }

            Console.WriteLine("════════════════════════════════════════════════════");
        }

        /// <summary>
        /// Get current portfolio status
        /// </summary>
        public virtual string GetPortfolioStatus()
        {
            return $"Cash: ${_portfolio.Cash:N2}, Total: ${_portfolio.TotalValue:N2}, Return: {_portfolio.TotalReturn:+0.00;-0.00;0.00}%";
        }

        /// <summary>
        /// Execute a buy order
        /// </summary>
        protected bool ExecuteBuy(string symbol, int quantity, double price, string? reasoning = null)
        {
            var totalCost = quantity * price;
            
            if (totalCost > _portfolio.Cash)
            {
                Console.WriteLine($"   ❌ Insufficient funds to buy {quantity} shares of {symbol}");
                return false;
            }

            _portfolio.Cash -= totalCost;

            if (_portfolio.Positions.ContainsKey(symbol))
            {
                var position = _portfolio.Positions[symbol];
                var totalShares = position.Quantity + quantity;
                var totalValue = (position.Quantity * position.AveragePrice) + totalCost;
                position.Quantity = totalShares;
                position.AveragePrice = totalValue / totalShares;
                position.CurrentPrice = price;
            }
            else
            {
                _portfolio.Positions[symbol] = new Position
                {
                    Symbol = symbol,
                    Quantity = quantity,
                    AveragePrice = price,
                    CurrentPrice = price
                };
            }

            var trade = new TradeAction
            {
                Symbol = symbol,
                Action = "buy",
                Quantity = quantity,
                Price = price,
                Timestamp = _currentDate,
                Reasoning = reasoning
            };
            _tradeHistory.Add(trade);

            Console.WriteLine($"   ✅ BUY: {quantity} shares of {symbol} @ ${price:N2} (Total: ${totalCost:N2})");
            return true;
        }

        /// <summary>
        /// Execute a sell order
        /// </summary>
        protected bool ExecuteSell(string symbol, int quantity, double price, string? reasoning = null)
        {
            if (!_portfolio.Positions.ContainsKey(symbol))
            {
                Console.WriteLine($"   ❌ No position in {symbol} to sell");
                return false;
            }

            var position = _portfolio.Positions[symbol];
            if (position.Quantity < quantity)
            {
                Console.WriteLine($"   ❌ Insufficient shares to sell {quantity} of {symbol} (have {position.Quantity})");
                return false;
            }

            var totalRevenue = quantity * price;
            _portfolio.Cash += totalRevenue;

            position.Quantity -= quantity;
            if (position.Quantity == 0)
            {
                _portfolio.Positions.Remove(symbol);
            }

            var trade = new TradeAction
            {
                Symbol = symbol,
                Action = "sell",
                Quantity = quantity,
                Price = price,
                Timestamp = _currentDate,
                Reasoning = reasoning
            };
            _tradeHistory.Add(trade);

            var pnl = (price - position.AveragePrice) * quantity;
            var pnlPercent = ((price - position.AveragePrice) / position.AveragePrice) * 100;

            Console.WriteLine($"   ✅ SELL: {quantity} shares of {symbol} @ ${price:N2} " +
                $"(Total: ${totalRevenue:N2}, P/L: {pnlPercent:+0.00;-0.00;0.00}%)");
            return true;
        }
    }
}
