using System;
using System.IO;
using System.Text.Json;
using AI_Trader.Models;

namespace AI_Trader.Tools
{
    /// <summary>
    /// Configuration loader utility
    /// </summary>
    public static class ConfigLoader
    {
        /// <summary>
        /// Load configuration from a JSON file
        /// </summary>
        public static AgentConfig LoadConfig(string configPath)
        {
            try
            {
                if (!File.Exists(configPath))
                {
                    throw new FileNotFoundException($"Configuration file not found: {configPath}");
                }

                var json = File.ReadAllText(configPath);
                var config = JsonSerializer.Deserialize<AgentConfig>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true,
                    ReadCommentHandling = JsonCommentHandling.Skip,
                    AllowTrailingCommas = true
                });

                if (config == null)
                {
                    throw new InvalidOperationException("Failed to deserialize configuration");
                }

                // Override with environment variables if available
                config.ApiKey ??= Environment.GetEnvironmentVariable("OPENAI_API_KEY");
                config.BaseUrl ??= Environment.GetEnvironmentVariable("OPENAI_BASE_URL");

                // Validate required fields
                ValidateConfig(config);

                return config;
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException($"Configuration file JSON format error: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Failed to load configuration: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Validate configuration has all required fields
        /// </summary>
        private static void ValidateConfig(AgentConfig config)
        {
            if (string.IsNullOrEmpty(config.AgentName))
            {
                throw new InvalidOperationException("Agent name is required");
            }

            if (string.IsNullOrEmpty(config.ModelName))
            {
                throw new InvalidOperationException("Model name is required");
            }

            if (config.StartDate == default)
            {
                throw new InvalidOperationException("Start date is required");
            }

            if (config.EndDate == default)
            {
                throw new InvalidOperationException("End date is required");
            }

            if (config.StartDate >= config.EndDate)
            {
                throw new InvalidOperationException("Start date must be before end date");
            }

            if (config.InitialCapital <= 0)
            {
                throw new InvalidOperationException("Initial capital must be greater than 0");
            }

            if (config.StockSymbols == null || config.StockSymbols.Count == 0)
            {
                throw new InvalidOperationException("At least one stock symbol is required");
            }
        }

        /// <summary>
        /// Save configuration to a JSON file
        /// </summary>
        public static void SaveConfig(AgentConfig config, string configPath)
        {
            try
            {
                var options = new JsonSerializerOptions
                {
                    WriteIndented = true,
                    Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
                };

                var json = JsonSerializer.Serialize(config, options);
                File.WriteAllText(configPath, json);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Failed to save configuration: {ex.Message}", ex);
            }
        }
    }
}
