require("codecompanion").setup({
  -- adapter for local ai in my port
  adapters = {
    http = {
      llama = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          formatted_name = "llama",
          env = {
            url = "http://localhost:8901",
          },
          handlers = {
            parse_message_meta = function(self, data)
              if data.extra and data.extra.reasoning_content then
                data.output.reasoning = { content = data.extra.reasoning_content }
              end  
              return data
            end,
          },
          schema = {
            model = {
              default = "fast",
              choices = { "fast", "tiel-coder", "general-purpose-qwen3.8" },
            },
          },
        })
      end,
    },
  },

  -- wire up interactions to use local ai and added web search tools
  interactions = {
    chat = {
      adapter = "llama",
      opts = {
        context_management = {
          compaction = { trigger = 55000, },
        },
      },
      tools = {
        ["web_search"] = {
          opts = {
            adapter = "duckduckgo",
          },
        },
        ["fetch_webpage"] = {
          opts = {
            adapter = "jina",
          },
        },
      },
    },
    inline = { adapter = "llama" },
  },
})

-- code companion keybinds
map("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", "CodeCompanion chat")
map("v", "<leader>cs", "<cmd>CodeCompanionChat Add<CR>", "Add Selection into chat")
map("v", "<leader>ci", "<cmd>CodeCompanion<CR>", "Inline prompt using selected context")
map("n", "<leader>cp", "<cmd>CodeCompanionActions<CR>", "Code Companion actions")
