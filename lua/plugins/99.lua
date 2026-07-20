-- ThePrimeagen/99 - AI agent for Neovim
-- https://github.com/ThePrimeagen/99
-- Uses the `opencode` CLI as its provider (default), which is already installed.
return {
	-- Register the <leader>9 prefix as a which-key group so the 99 keybinds
	-- are discoverable. Per-keymap labels come from the `desc` fields below.
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>9", group = "99 (AI)", icon = "" },
			},
		},
	},
	{
		"ThePrimeagen/99",
		-- fzf-lua powers the model/provider pickers (<leader>9m / <leader>9p).
		-- The `fzf` binary is already installed system-wide.
		dependencies = { "ibhagwan/fzf-lua" },
		keys = {
			{ "<leader>9v", mode = "v", desc = "99: Vibe on visual selection" },
			{ "<leader>9s", desc = "99: Search" },
			{ "<leader>9x", desc = "99: Stop all requests" },
			{ "<leader>9o", desc = "99: Open last interaction" },
			{ "<leader>9l", desc = "99: View logs" },
			{ "<leader>9m", desc = "99: Select model" },
			{ "<leader>9p", desc = "99: Select provider" },
		},
		config = function()
			local _99 = require("99")

			local cwd = vim.uv.cwd()
			local basename = vim.fs.basename(cwd)

			_99.setup({
				-- Default provider is OpenCodeProvider (uses the `opencode` CLI).
				logger = {
					level = _99.DEBUG,
					path = "/tmp/" .. basename .. ".99.debug",
					print_on_error = true,
				},
				tmp_dir = "./tmp",
				md_files = {
					"AGENT.md",
					"AGENTS.md",
				},
			})

			-- Visual-mode only: send the current visual selection + a prompt and
			-- replace the selection with the result.
			vim.keymap.set("v", "<leader>9v", function()
				_99.visual()
			end, { desc = "99: Vibe on visual selection" })

			-- Search across the project; results land in the quickfix list.
			vim.keymap.set("n", "<leader>9s", function()
				_99.search()
			end, { desc = "99: Search" })

			-- Cancel/kill all in-flight requests.
			vim.keymap.set("n", "<leader>9x", function()
				_99.stop_all_requests()
			end, { desc = "99: Stop all requests" })

			-- Open the last interaction (qfix for search/vibe, etc).
			vim.keymap.set("n", "<leader>9o", function()
				_99.open()
			end, { desc = "99: Open last interaction" })

			-- View the most recent run's logs.
			vim.keymap.set("n", "<leader>9l", function()
				_99.view_logs()
			end, { desc = "99: View logs" })

			-- Model / provider pickers via fzf-lua (LazyVim's default picker).
			vim.keymap.set("n", "<leader>9m", function()
				require("99.extensions.fzf_lua").select_model()
			end, { desc = "99: Select model" })

			vim.keymap.set("n", "<leader>9p", function()
				require("99.extensions.fzf_lua").select_provider()
			end, { desc = "99: Select provider" })
		end,
	},
}
