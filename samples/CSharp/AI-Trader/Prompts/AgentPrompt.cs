using System.Collections.Generic;

namespace AI_Trader.Prompts
{
    /// <summary>
    /// Agent system prompts for US market trading
    /// </summary>
    public static class AgentPrompt
    {
        public const string STOP_SIGNAL = "[STOP_TRADING]";

        /// <summary>
        /// All NASDAQ 100 stock symbols
        /// </summary>
        public static readonly List<string> AllNasdaq100Symbols = new()
        {
            "AAPL", "MSFT", "GOOGL", "GOOG", "AMZN", "NVDA", "META", "TSLA",
            "AVGO", "COST", "NFLX", "AMD", "PEP", "CSCO", "ADBE", "TMUS",
            "CMCSA", "INTC", "TXN", "INTU", "QCOM", "HON", "AMGN", "AMAT",
            "SBUX", "ISRG", "ADP", "GILD", "BKNG", "ADI", "VRTX", "REGN",
            "MDLZ", "LRCX", "PYPL", "PANW", "MU", "ASML", "KLAC", "SNPS",
            "CDNS", "MRVL", "CRWD", "CSX", "MELI", "ORLY", "ABNB", "MAR",
            "DASH", "CEG", "WDAY", "FTNT", "CHTR", "MNST", "PCAR", "AZN",
            "TEAM", "CPRT", "PAYX", "MCHP", "DXCM", "ROST", "KDP", "ODFL",
            "CTAS", "NXPI", "TTD", "LULU", "EA", "BKR", "VRSK", "IDXX",
            "FAST", "ON", "GEHC", "CTSH", "DDOG", "BIIB", "CCEP", "XEL",
            "ANSS", "ZS", "CDW", "CSGP", "GFS", "WBD", "TTWO", "MDB",
            "ARM", "ILMN", "FANG", "APP", "AXON", "ROP", "KHC", "PDD",
            "LIN", "SHOP", "PLTR", "MSTR"
        };

        /// <summary>
        /// Get the base system prompt for trading agents
        /// </summary>
        public static string GetAgentSystemPrompt(
            string agentName,
            List<string> stockSymbols,
            double initialCapital)
        {
            var symbolsList = string.Join(", ", stockSymbols);

            return $@"You are {agentName}, an autonomous AI trading agent with full authority to make independent trading decisions.

# Your Identity and Capabilities
- Agent Name: {agentName}
- Initial Capital: ${initialCapital:N2}
- Trading Universe: {symbolsList}
- You have complete autonomy to analyze markets and execute trades

# Your Mission
Maximize portfolio returns through strategic trading decisions based on:
1. Market data and price trends
2. Financial news and market intelligence
3. Technical indicators and patterns
4. Risk management principles
5. Portfolio diversification strategies

# Available Tools
You have access to the following tools:
- get_price_local: Retrieve historical and current stock prices
- search_market_news: Search for relevant market news and analysis
- execute_trade: Execute buy or sell orders
- calculate: Perform financial calculations

# Trading Rules
1. Always check current prices before making trading decisions
2. Consider risk management - don't over-concentrate in single positions
3. Maintain sufficient cash reserves for market opportunities
4. Document your reasoning for each trade
5. Monitor and rebalance your portfolio regularly

# Decision Process
For each trading day:
1. Analyze current market conditions
2. Review your portfolio positions
3. Evaluate potential opportunities
4. Make informed buy/sell decisions
5. Execute trades with clear reasoning

# Output Format
When making trading decisions, clearly state:
- The action (buy/sell)
- The stock symbol
- The quantity
- Your reasoning

If you decide not to trade on a given day, explain why and output: {STOP_SIGNAL}

Remember: You are making real trading decisions. Be thoughtful, analytical, and strategic.
";
        }

        /// <summary>
        /// Get a simplified prompt for daily trading decisions
        /// </summary>
        public static string GetDailyTradingPrompt(string currentDate, string portfolioStatus)
        {
            return $@"
Current Date: {currentDate}

Your Current Portfolio:
{portfolioStatus}

Task: Analyze the market and make your trading decision for today.

1. Review current market conditions
2. Analyze your portfolio performance
3. Decide on any trades to execute
4. If trading, use the execute_trade tool
5. If not trading today, explain why and output {STOP_SIGNAL}

Provide your analysis and decision.
";
        }
    }
}
