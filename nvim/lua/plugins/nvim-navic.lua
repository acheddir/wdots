return {
    "smiteshp/nvim-navic",
    config = function()
        require("nvim-navic").setup({
            lsp = {
                -- priority order for attaching LSP servers
                -- to the current buffer
                preference = {
                    "html",
                    "templ",
                },
            },
            separator = " 󰁔 ",
        })
    end,
}
