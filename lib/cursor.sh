install_cursor_extensions() {
  local extensions=(
    "anweber.reveal-button"
    "atomiks.moonlight"
    # Optional if you regularly write Mermaid diagrams in docs.
    "bierner.markdown-mermaid"
    "biomejs.biome"
    "bradlc.vscode-tailwindcss"
    "coderabbit.coderabbit-vscode"
    "davidanson.vscode-markdownlint"
    "eamodio.gitlens"
    "esbenp.prettier-vscode"
    "github.vscode-github-actions"
    "mikestead.dotenv"
    "ms-playwright.playwright"
    "openai.chatgpt"
    "pflannery.vscode-versionlens"
    "prisma.prisma"
    "streetsidesoftware.code-spell-checker"
    "unifiedjs.vscode-mdx"
    "usernamehw.errorlens"
    "vitest.explorer"
    "yoavbls.pretty-ts-errors"
  )

  if ! command -v cursor >/dev/null 2>&1; then
    echo "Skipping Cursor extensions; install the Cursor CLI and rerun Genesis"
    return
  fi

  local extension
  for extension in "${extensions[@]}"; do
    cursor --install-extension "${extension}"
  done
}
