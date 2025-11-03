using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace AI_Trader.Models
{
    /// <summary>
    /// Configuration for a trading agent
    /// </summary>
    public class AgentConfig
    {
        [JsonPropertyName("agent_name")]
        public string AgentName { get; set; } = "BaseAgent";

        [JsonPropertyName("agent_type")]
        public string AgentType { get; set; } = "BaseAgent";

        [JsonPropertyName("model_name")]
        public string ModelName { get; set; } = "gpt-4";

        [JsonPropertyName("start_date")]
        public DateTime StartDate { get; set; }

        [JsonPropertyName("end_date")]
        public DateTime EndDate { get; set; }

        [JsonPropertyName("initial_capital")]
        public double InitialCapital { get; set; } = 10000.0;

        [JsonPropertyName("stock_symbols")]
        public List<string> StockSymbols { get; set; } = new();

        [JsonPropertyName("trading_frequency")]
        public string TradingFrequency { get; set; } = "daily";

        [JsonPropertyName("temperature")]
        public double Temperature { get; set; } = 0.7;

        [JsonPropertyName("max_tokens")]
        public int MaxTokens { get; set; } = 4096;

        [JsonPropertyName("api_key")]
        public string? ApiKey { get; set; }

        [JsonPropertyName("base_url")]
        public string? BaseUrl { get; set; }

        [JsonPropertyName("enable_logging")]
        public bool EnableLogging { get; set; } = true;

        [JsonPropertyName("log_directory")]
        public string LogDirectory { get; set; } = "logs";
    }

    /// <summary>
    /// Represents a trade action
    /// </summary>
    public class TradeAction
    {
        [JsonPropertyName("symbol")]
        public string Symbol { get; set; } = "";

        [JsonPropertyName("action")]
        public string Action { get; set; } = ""; // "buy" or "sell"

        [JsonPropertyName("quantity")]
        public int Quantity { get; set; }

        [JsonPropertyName("price")]
        public double Price { get; set; }

        [JsonPropertyName("timestamp")]
        public DateTime Timestamp { get; set; }

        [JsonPropertyName("reasoning")]
        public string? Reasoning { get; set; }
    }

    /// <summary>
    /// Represents a portfolio position
    /// </summary>
    public class Position
    {
        [JsonPropertyName("symbol")]
        public string Symbol { get; set; } = "";

        [JsonPropertyName("quantity")]
        public int Quantity { get; set; }

        [JsonPropertyName("average_price")]
        public double AveragePrice { get; set; }

        [JsonPropertyName("current_price")]
        public double CurrentPrice { get; set; }

        [JsonPropertyName("market_value")]
        public double MarketValue => Quantity * CurrentPrice;

        [JsonPropertyName("unrealized_pnl")]
        public double UnrealizedPnL => (CurrentPrice - AveragePrice) * Quantity;

        [JsonPropertyName("unrealized_pnl_percent")]
        public double UnrealizedPnLPercent => AveragePrice > 0 ? ((CurrentPrice - AveragePrice) / AveragePrice) * 100 : 0;
    }

    /// <summary>
    /// Represents a portfolio state
    /// </summary>
    public class Portfolio
    {
        [JsonPropertyName("cash")]
        public double Cash { get; set; }

        [JsonPropertyName("positions")]
        public Dictionary<string, Position> Positions { get; set; } = new();

        [JsonPropertyName("total_value")]
        public double TotalValue
        {
            get
            {
                double positionsValue = 0;
                foreach (var position in Positions.Values)
                {
                    positionsValue += position.MarketValue;
                }
                return Cash + positionsValue;
            }
        }

        [JsonPropertyName("initial_capital")]
        public double InitialCapital { get; set; }

        [JsonPropertyName("total_return")]
        public double TotalReturn => InitialCapital > 0 ? ((TotalValue - InitialCapital) / InitialCapital) * 100 : 0;
    }

    /// <summary>
    /// Represents historical price data for a stock
    /// </summary>
    public class PriceData
    {
        [JsonPropertyName("symbol")]
        public string Symbol { get; set; } = "";

        [JsonPropertyName("date")]
        public DateTime Date { get; set; }

        [JsonPropertyName("open")]
        public double Open { get; set; }

        [JsonPropertyName("high")]
        public double High { get; set; }

        [JsonPropertyName("low")]
        public double Low { get; set; }

        [JsonPropertyName("close")]
        public double Close { get; set; }

        [JsonPropertyName("volume")]
        public long Volume { get; set; }
    }

    /// <summary>
    /// Result of a tool execution
    /// </summary>
    public class ToolResult
    {
        [JsonPropertyName("success")]
        public bool Success { get; set; }

        [JsonPropertyName("data")]
        public object? Data { get; set; }

        [JsonPropertyName("error")]
        public string? Error { get; set; }

        [JsonPropertyName("message")]
        public string? Message { get; set; }
    }
}
