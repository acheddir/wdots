return {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
        local dap = require("dap")
        if not dap.adapters["netcoredbg"] then
            require("dap").adapters["netcoredbg"] = {
                type = "executable",
                command = vim.fn.exepath("netcoredbg"),
                args = { "--interpreter=vscode" },
                options = {
                    detached = false,
                },
            }
        end
    end,
}
