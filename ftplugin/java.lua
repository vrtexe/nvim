local ok, jdtls = pcall(require, "jdtls")
if not ok then return end
local root = vim.fs.root(0, { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" })
if not root then return end
local mason = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local ws = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")
jdtls.start_or_attach({
  cmd = { mason .. "/bin/jdtls", "-data", ws },
  root_dir = root,
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
