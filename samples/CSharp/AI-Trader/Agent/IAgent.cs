using System.Threading.Tasks;

namespace AI_Trader.Agent
{
    /// <summary>
    /// Interface for trading agents
    /// </summary>
    public interface IAgent
    {
        /// <summary>
        /// Initialize the agent
        /// </summary>
        Task InitializeAsync();

        /// <summary>
        /// Run the trading session
        /// </summary>
        Task RunAsync();

        /// <summary>
        /// Get current portfolio status
        /// </summary>
        string GetPortfolioStatus();
    }
}
