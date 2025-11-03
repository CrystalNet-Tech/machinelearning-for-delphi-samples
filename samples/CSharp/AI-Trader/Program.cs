using System;
using System.Threading.Tasks;
using AI_Trader.Agent;
using AI_Trader.Models;
using AI_Trader.Tools;
using DotNetEnv;

namespace AI_Trader
{
    /// <summary>
    /// Main entry point for the AI-Trader application
    /// </summary>
    class Program
    {
        static async Task Main(string[] args)
        {
            try
            {
                // Load environment variables from .env file
                Env.Load();

                Console.WriteLine("╔══════════════════════════════════════════════════╗");
                Console.WriteLine("║          🤖 AI-Trader C# Edition                 ║");
                Console.WriteLine("║     Autonomous AI Trading Agent System           ║");
                Console.WriteLine("╚══════════════════════════════════════════════════╝");
                Console.WriteLine();

                // Parse command line arguments
                string? configPath = null;
                if (args.Length > 0)
                {
                    configPath = args[0];
                    Console.WriteLine($"📄 Using configuration file: {configPath}");
                }
                else
                {
                    configPath = "configs/default_config.json";
                    Console.WriteLine($"📄 Using default configuration: {configPath}");
                }

                // Run the trading agent
                await RunTradingAgentAsync(configPath);

                Console.WriteLine();
                Console.WriteLine("✅ Trading session completed successfully!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                Environment.Exit(1);
            }
        }

        /// <summary>
        /// Initialize and run the trading agent
        /// </summary>
        private static async Task RunTradingAgentAsync(string configPath)
        {
            // Load configuration
            Console.WriteLine($"📥 Loading configuration from: {configPath}");
            var config = ConfigLoader.LoadConfig(configPath);

            if (config == null)
            {
                throw new InvalidOperationException("Failed to load configuration");
            }

            Console.WriteLine($"✅ Configuration loaded successfully");
            Console.WriteLine($"   Agent: {config.AgentName}");
            Console.WriteLine($"   Model: {config.ModelName}");
            Console.WriteLine($"   Period: {config.StartDate:yyyy-MM-dd} to {config.EndDate:yyyy-MM-dd}");
            Console.WriteLine($"   Initial Capital: ${config.InitialCapital:N2}");
            Console.WriteLine();

            // Get the appropriate agent class
            var agentClass = GetAgentClass(config.AgentType);
            Console.WriteLine($"✅ Successfully loaded Agent class: {config.AgentType}");
            Console.WriteLine();

            // Create agent instance
            var agent = agentClass(config);

            // Initialize the agent
            Console.WriteLine("🔧 Initializing agent...");
            await agent.InitializeAsync();
            Console.WriteLine("✅ Agent initialized successfully");
            Console.WriteLine();

            // Run the trading session
            Console.WriteLine("🚀 Starting trading session...");
            Console.WriteLine("════════════════════════════════════════════════════");
            await agent.RunAsync();
            Console.WriteLine("════════════════════════════════════════════════════");
        }

        /// <summary>
        /// Get the appropriate agent class based on agent type
        /// </summary>
        private static Func<AgentConfig, IAgent> GetAgentClass(string agentType)
        {
            return agentType switch
            {
                "BaseAgent" => config => new BaseAgent(config),
                "BaseAgent_Hour" => config => new BaseAgentHour(config),
                "BaseAgent_AStock" => config => new BaseAgentAStock(config),
                _ => throw new ArgumentException($"Unsupported agent type: {agentType}. " +
                    $"Supported types: BaseAgent, BaseAgent_Hour, BaseAgent_AStock")
            };
        }
    }
}
