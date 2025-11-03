<div align="center">

# 🚀 AI-Trader C# Edition: Can AI Beat the Market?

[![C#](https://img.shields.io/badge/C%23-.NET%208.0-blue.svg)](https://dotnet.microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Original](https://img.shields.io/badge/Original-Python-yellow.svg)](https://github.com/HKUDS/AI-Trader)

**C# port of the AI-Trader project - AI agents battle for supremacy in NASDAQ 100 and SSE 50 markets.**

This is a C# conversion of the original [AI-Trader Python project](https://github.com/HKUDS/AI-Trader) by HKUDS, bringing autonomous AI trading agents to the .NET ecosystem.

</div>

---

## 🌟 Project Introduction

> **AI-Trader enables distinct AI models, each employing unique investment strategies, to compete autonomously in the same market and determine which can generate the highest profits in NASDAQ 100 or SSE 50 trading!**

This C# port maintains the core functionality of the original Python implementation while leveraging .NET's ecosystem and performance characteristics.

### 🎯 Core Features

- 🤖 **Fully Autonomous Decision-Making**: AI agents perform 100% independent analysis, decision-making, and execution without human intervention
- 🛠️ **Pure Tool-Driven Architecture**: Enabling AI to complete all trading operations through standardized tool calls
- 🏆 **Multi-Model Competition Arena**: Deploy multiple AI models (GPT, Claude, Qwen, etc.) for competitive trading
- 📊 **Real-Time Performance Analytics**: Comprehensive trading records, position monitoring, and profit/loss analysis
- 🔍 **Intelligent Market Intelligence**: Integrated search for real-time market news and financial reports
- 🔌 **Extensible Strategy Framework**: Support for third-party strategies and custom AI agent integration
- ⏰ **Historical Replay Capability**: Time-period replay functionality with automatic future information filtering

---

## 🚀 Quick Start

### Prerequisites

- .NET 8.0 SDK or later
- OpenAI API key or compatible API endpoint
- (Optional) Alpha Vantage API key for US market data
- (Optional) Tushare token for A-share market data

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/CrystalNet-Tech/machinelearning-for-delphi-samples.git
   cd machinelearning-for-delphi-samples/samples/CSharp/AI-Trader
   ```

2. **Install dependencies**
   ```bash
   dotnet restore
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the project root:
   ```env
   # Required: OpenAI API Configuration
   OPENAI_API_KEY=your_openai_api_key_here
   OPENAI_BASE_URL=https://api.openai.com/v1
   
   # Optional: Market Data APIs
   ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key
   TUSHARE_TOKEN=your_tushare_token
   
   # Agent Configuration
   SIGNATURE=my_agent_v1
   ```

4. **Configure your agent**
   
   Edit or create a configuration file in `configs/`:
   ```json
   {
     "agent_name": "MyTradingAgent",
     "agent_type": "BaseAgent",
     "model_name": "gpt-4",
     "start_date": "2024-01-01",
     "end_date": "2024-12-31",
     "initial_capital": 10000.0,
     "stock_symbols": ["AAPL", "MSFT", "NVDA", "GOOGL", "META"]
   }
   ```

5. **Build and run**
   ```bash
   dotnet build
   dotnet run
   ```

---

## 📁 Project Structure

```
AI-Trader/
├── Agent/                    # Trading agent implementations
│   ├── BaseAgent.cs         # Base agent class with core functionality
│   ├── BaseAgentHour.cs     # Hour-level trading agent
│   └── BaseAgentAStock.cs   # A-share market agent
├── AgentTools/              # MCP tool implementations
│   ├── ToolJinaSearch.cs   # Market intelligence search
│   ├── ToolMath.cs         # Mathematical calculations
│   ├── ToolGetPriceLocal.cs # Local price data retrieval
│   └── ToolTrade.cs        # Trading execution
├── Tools/                   # Utility functions
│   ├── GeneralTools.cs     # General purpose utilities
│   ├── PriceTools.cs       # Price data processing
│   └── ResultTools.cs      # Results analysis
├── Prompts/                 # Agent system prompts
│   ├── AgentPrompt.cs      # US market prompts
│   └── AgentPromptAStock.cs # A-share market prompts
├── Data/                    # Market data storage
│   ├── agent_data/         # Agent runtime data
│   └── daily_prices_*.json # Historical price data
├── Configs/                 # Configuration files
│   ├── default_config.json
│   ├── default_day_config.json
│   └── default_hour_config.json
├── Program.cs               # Application entry point
└── AI-Trader.csproj         # Project file
```

---

## 🛠️ Key Components

### BaseAgent Class
The core agent class that encapsulates:
- AI model integration and chat completion
- Tool management and execution
- Trading decision logic
- Position and portfolio management
- Performance tracking and logging

### Trading Tools
- **ToolGetPriceLocal**: Retrieve historical and current price data
- **ToolTrade**: Execute buy/sell orders with position tracking
- **ToolJinaSearch**: Search market news and intelligence
- **ToolMath**: Perform financial calculations

### Configuration System
- JSON-based configuration files
- Environment variable support via .env files
- Runtime configuration persistence
- Support for multiple agent profiles

---

## 💡 Usage Examples

### Basic Trading Agent
```csharp
using AI_Trader.Agent;
using AI_Trader.Tools;

// Load configuration
var config = ConfigLoader.LoadConfig("configs/default_config.json");

// Create and initialize agent
var agent = new BaseAgent(config);
await agent.InitializeAsync();

// Run trading session
await agent.RunAsync();
```

### Custom Strategy Implementation
```csharp
public class MyCustomAgent : BaseAgent
{
    public MyCustomAgent(AgentConfig config) : base(config)
    {
    }
    
    protected override async Task<string> GenerateSystemPromptAsync()
    {
        // Implement your custom strategy prompt
        return "Your custom trading strategy instructions...";
    }
}
```

---

## 🎮 Trading Environment

- 💰 **Initial Capital**: $10,000 USD or 100,000¥ CNY starting balance
- 📈 **Trading Universe**: NASDAQ 100 component stocks or SSE 50 component stocks
- ⏰ **Trading Schedule**: Weekday market hours with historical simulation support
- 📊 **Data Integration**: Alpha Vantage API for US markets, Tushare for A-shares
- 🔄 **Time Management**: Historical period replay with automated future information filtering

---

## 📊 Configuration Guide

### Agent Configuration Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `agent_name` | string | Unique identifier for the agent | "BaseAgent" |
| `agent_type` | string | Type of agent class to use | "BaseAgent" |
| `model_name` | string | AI model to use (e.g., gpt-4, claude-3) | "gpt-4" |
| `start_date` | string | Trading start date (YYYY-MM-DD) | Required |
| `end_date` | string | Trading end date (YYYY-MM-DD) | Required |
| `initial_capital` | double | Starting capital amount | 10000.0 |
| `stock_symbols` | array | List of stock tickers to trade | NASDAQ 100 |
| `trading_frequency` | string | "daily" or "hourly" | "daily" |

---

## 🔧 Development

### Building from Source
```bash
# Restore dependencies
dotnet restore

# Build the project
dotnet build --configuration Release

# Run tests (if available)
dotnet test
```

### Adding Custom Tools
1. Create a new class implementing the tool interface
2. Register the tool in the agent's tool registry
3. Add tool description and parameters
4. Implement the tool execution logic

Example:
```csharp
public class CustomTool : IAgentTool
{
    public string Name => "custom_tool";
    public string Description => "Description of what this tool does";
    
    public async Task<ToolResult> ExecuteAsync(Dictionary<string, object> parameters)
    {
        // Implement custom tool logic
        return new ToolResult { Success = true, Data = result };
    }
}
```

---

## 🚀 Roadmap

### Completed
- ✅ Core agent framework conversion to C#
- ✅ Trading tools implementation
- ✅ Configuration system
- ✅ Price data management
- ✅ Basic US market support

### Planned
- [ ] Full A-Share market support
- [ ] Enhanced logging and monitoring
- [ ] Web-based dashboard UI
- [ ] Advanced technical analysis tools
- [ ] Backtesting framework
- [ ] Real-time trading support
- [ ] Multi-threading optimization

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

This C# port is based on the original [AI-Trader Python project](https://github.com/HKUDS/AI-Trader) by HKUDS.

Thanks to:
- [HKUDS/AI-Trader](https://github.com/HKUDS/AI-Trader) - Original Python implementation
- [LangChain](https://github.com/langchain-ai/langchain) - AI application framework
- [Betalgo.OpenAI](https://github.com/betalgo/openai) - OpenAI C# SDK
- [Alpha Vantage](https://www.alphavantage.co/) - US stock market data
- [Tushare](https://tushare.pro/) - China A-share market data

---

## Disclaimer

The materials provided by the AI-Trader project are for research and educational purposes only and do not constitute any investment advice. Investors should seek independent professional advice before making any investment decisions. Past performance should not be taken as an indicator of future results. The value of investments may go up as well as down, and there is no guarantee of returns. All content is provided solely for research purposes and does not constitute a recommendation to invest. Investing involves risks. Please seek professional advice if needed.

---

<div align="center">

**🌟 This is a C# educational port for the .NET community**

**Original Python Project:** [HKUDS/AI-Trader](https://github.com/HKUDS/AI-Trader)

</div>
