return {
  {
    "the-coding-doggo/batman.nvim",
    opts = {
      theme = "arkham",
      use_persistence = true,
    },
  }
,
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
	"nvim-tree/nvim-web-devicons"
    },
    opts = {
	theme = "auto"
    }

  }
}

