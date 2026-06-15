return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- This tells lazy to use the legacy branch
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs") -- This will work again safely
        configs.setup({
            highlight = {
                enable = true
            },
            indent = {
                enable = true
            },
            autotag = {
                enable = true
            },
            ensure_installed = {
                "lua", "vim", "vimdoc", "bash", "markdown",
                "json", "yaml", "toml",
                "html", "css", "javascript", "typescript", "tsx",
                "python", "go", "c", "cpp",
                "regex", "query", "gitignore"
            },
            auto_install = false
        })
    end
}
