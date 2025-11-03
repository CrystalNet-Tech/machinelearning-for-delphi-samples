using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Linq;
using AI_Trader.Models;

namespace AI_Trader.Tools
{
    /// <summary>
    /// General utility tools for configuration management and message processing
    /// </summary>
    public static class GeneralTools
    {
        private static Dictionary<string, object>? _runtimeEnv = null;
        private static string? _runtimeEnvPath = null;

        /// <summary>
        /// Resolve the runtime environment path
        /// </summary>
        private static string ResolveRuntimeEnvPath()
        {
            if (_runtimeEnvPath != null)
                return _runtimeEnvPath;

            var path = Environment.GetEnvironmentVariable("RUNTIME_ENV_PATH");
            
            if (string.IsNullOrEmpty(path))
            {
                var signature = Environment.GetEnvironmentVariable("SIGNATURE");
                if (!string.IsNullOrEmpty(signature))
                {
                    var baseDir = Path.GetDirectoryName(typeof(GeneralTools).Assembly.Location);
                    var defaultPath = Path.Combine(baseDir!, "data", "agent_data", signature, ".runtime_env.json");
                    
                    // Ensure parent directory exists
                    var parentDir = Path.GetDirectoryName(defaultPath);
                    if (parentDir != null && !Directory.Exists(parentDir))
                    {
                        Directory.CreateDirectory(parentDir);
                    }
                    
                    path = defaultPath;
                    Environment.SetEnvironmentVariable("RUNTIME_ENV_PATH", path);
                }
            }

            _runtimeEnvPath = path ?? "";
            return _runtimeEnvPath;
        }

        /// <summary>
        /// Load runtime environment configuration
        /// </summary>
        private static Dictionary<string, object> LoadRuntimeEnv()
        {
            if (_runtimeEnv != null)
                return _runtimeEnv;

            var path = ResolveRuntimeEnvPath();
            if (string.IsNullOrEmpty(path))
            {
                _runtimeEnv = new Dictionary<string, object>();
                return _runtimeEnv;
            }

            try
            {
                if (File.Exists(path))
                {
                    var json = File.ReadAllText(path);
                    var data = JsonSerializer.Deserialize<Dictionary<string, object>>(json);
                    _runtimeEnv = data ?? new Dictionary<string, object>();
                    return _runtimeEnv;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️  Warning: Failed to load runtime environment: {ex.Message}");
            }

            _runtimeEnv = new Dictionary<string, object>();
            return _runtimeEnv;
        }

        /// <summary>
        /// Get a configuration value from runtime environment or environment variables
        /// </summary>
        public static T? GetConfigValue<T>(string key, T? defaultValue = default)
        {
            var runtimeEnv = LoadRuntimeEnv();

            if (runtimeEnv.ContainsKey(key))
            {
                try
                {
                    var value = runtimeEnv[key];
                    if (value is JsonElement jsonElement)
                    {
                        return JsonSerializer.Deserialize<T>(jsonElement.GetRawText());
                    }
                    return (T)Convert.ChangeType(value, typeof(T));
                }
                catch
                {
                    // Fall through to environment variable
                }
            }

            var envValue = Environment.GetEnvironmentVariable(key);
            if (!string.IsNullOrEmpty(envValue))
            {
                try
                {
                    return (T)Convert.ChangeType(envValue, typeof(T));
                }
                catch
                {
                    // Fall through to default
                }
            }

            return defaultValue;
        }

        /// <summary>
        /// Write a configuration value to runtime environment
        /// </summary>
        public static void WriteConfigValue(string key, object value)
        {
            var path = ResolveRuntimeEnvPath();
            if (string.IsNullOrEmpty(path))
            {
                Console.WriteLine($"⚠️  WARNING: RUNTIME_ENV_PATH not set, config value '{key}' not persisted");
                return;
            }

            var runtimeEnv = LoadRuntimeEnv();
            runtimeEnv[key] = value;

            try
            {
                var options = new JsonSerializerOptions
                {
                    WriteIndented = true,
                    Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
                };
                var json = JsonSerializer.Serialize(runtimeEnv, options);
                File.WriteAllText(path, json);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error writing config to {path}: {ex.Message}");
            }
        }

        /// <summary>
        /// Clear cached runtime environment (useful for testing)
        /// </summary>
        public static void ClearCache()
        {
            _runtimeEnv = null;
            _runtimeEnvPath = null;
        }

        /// <summary>
        /// Extract conversation information from messages
        /// </summary>
        public static string? ExtractConversation(Dictionary<string, object> conversation, string outputType)
        {
            if (!conversation.ContainsKey("messages"))
                return outputType == "all" ? "[]" : null;

            var messages = conversation["messages"];
            var messageList = messages as List<object> ?? new List<object>();

            if (outputType == "all")
            {
                return JsonSerializer.Serialize(messageList);
            }

            if (outputType == "final")
            {
                // Get the last message with finish_reason == 'stop' and non-empty content
                foreach (var msg in messageList.Cast<Dictionary<string, object>>().Reverse())
                {
                    var finishReason = GetNestedValue(msg, new[] { "response_metadata", "finish_reason" }) as string;
                    var content = GetNestedValue(msg, new[] { "content" }) as string;
                    
                    if (finishReason == "stop" && !string.IsNullOrWhiteSpace(content))
                    {
                        return content;
                    }
                }

                // Fallback: return the last message content
                if (messageList.Count > 0)
                {
                    var lastMsg = messageList.Last() as Dictionary<string, object>;
                    if (lastMsg != null && lastMsg.ContainsKey("content"))
                    {
                        return lastMsg["content"] as string;
                    }
                }
            }

            return null;
        }

        /// <summary>
        /// Extract tool call messages from conversation
        /// </summary>
        public static List<Dictionary<string, object>> ExtractToolMessages(
            Dictionary<string, object> conversation)
        {
            var toolMessages = new List<Dictionary<string, object>>();

            if (!conversation.ContainsKey("messages"))
                return toolMessages;

            var messages = conversation["messages"] as List<object>;
            if (messages == null)
                return toolMessages;

            foreach (var msg in messages.Cast<Dictionary<string, object>>())
            {
                var type = msg.GetValueOrDefault("type") as string;
                if (type == "tool")
                {
                    toolMessages.Add(msg);
                }
            }

            return toolMessages;
        }

        /// <summary>
        /// Get nested value from dictionary
        /// </summary>
        private static object? GetNestedValue(Dictionary<string, object> dict, string[] path)
        {
            object? current = dict;
            
            foreach (var key in path)
            {
                if (current is Dictionary<string, object> currentDict)
                {
                    if (!currentDict.ContainsKey(key))
                        return null;
                    current = currentDict[key];
                }
                else
                {
                    return null;
                }
            }

            return current;
        }
    }
}
