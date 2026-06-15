return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local autopairs = require("nvim-autopairs")

		autopairs.setup({
			check_ts = true, -- Enable Treesitter integration if you use it
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
		})

		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp_status, cmp = pcall(require, "cmp")
		if cmp_status then
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end
	end,
}
