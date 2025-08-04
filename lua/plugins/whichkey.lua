
local wk = require("which-key")

wk.register({
	f = {
		name = "Find",
		f = {"Find File"},
		t = {"Find Text"},
		b = {"Find Buffer"},
		h = {"Find Help"},
	},

	g = {
		name = "Git",
		b = "Open Branches",
		c = "Open Commits",
		s = "Open Status",
        h = "Git: File History",
        d = "Git Diff: HEAD~1",
	},

    e = {"Open Diagnostic Window"},

    l = {
        name = "LSP",
        D = "Declaration",
        d = "Definition",
        k = "Hover",
    },

    t = {
        name = "NvimTree",
        t = "Tree Toggle",
        f = "Tree Focus",
    },

    n = {
        name = "TodoList",
        l = "Open List"
    },

    s = {"Open Terminal"},

    r = {"Ruff"},

    c = {
        name = "Color Schemes",
        s = "Open"
    },

    
    p = {
        name = "Run Python File",
        t = "Python Runner Toggle",
        r = "Python Runner",
    }

}, {prefix = "<leader>"})
