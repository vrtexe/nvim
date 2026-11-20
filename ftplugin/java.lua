local ok, jdtls = pcall(require, "jdtls")
if not ok then return end
local root = vim.fs.root(0, { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" })
if not root then return end
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local ws = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")

-- java-debug-adapter + java-test bundles: nvim-jdtls registers the dap adapter
-- and test commands when the server reports them. These two java-test jars are
-- not OSGi bundles and make jdtls fail to load the rest.
local bundles =
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
for _, jar in ipairs(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", true, true)) do
  local name = vim.fn.fnamemodify(jar, ":t")
  if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
    bundles[#bundles + 1] = jar
  end
end

jdtls.start_or_attach({
  cmd = { mason .. "/jdtls/bin/jdtls", "--jvm-arg=-javaagent:" .. mason .. "/jdtls/lombok.jar", "-data", ws },
  root_dir = root,
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  init_options = { bundles = bundles },
})
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
