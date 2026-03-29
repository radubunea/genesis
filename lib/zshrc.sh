ensure_oh_my_zsh_git_plugin() {
  local zshrc_path="$1"

  if ! grep -Fq "oh-my-zsh.sh" "${zshrc_path}" 2>/dev/null; then
    echo "Skipping Oh My Zsh plugin config; oh-my-zsh.sh is not referenced in ${zshrc_path}"
    return
  fi

  local plugins_line=""
  plugins_line="$(grep -E '^[[:space:]]*plugins=\(' "${zshrc_path}" || true)"

  if [[ -n "${plugins_line}" ]]; then
    local plugin_contents="${plugins_line#*\(}"
    plugin_contents="${plugin_contents%\)*}"

    if [[ " ${plugin_contents} " == *" git "* ]]; then
      echo "Skipping Oh My Zsh plugin config; git is already enabled"
      return
    fi

    local plugins_tmp_file
    plugins_tmp_file="$(mktemp)"

    awk '
      BEGIN {
        updated = 0
      }
      /^[[:space:]]*plugins=\(/ && updated == 0 {
        sub(/\)[[:space:]]*$/, " git)")
        updated = 1
      }
      {
        print
      }
      END {
        if (updated == 0) {
          exit 1
        }
      }
    ' "${zshrc_path}" > "${plugins_tmp_file}"

    mv "${plugins_tmp_file}" "${zshrc_path}"
    echo "Enabled Oh My Zsh git plugin"
    return
  fi

  local source_tmp_file
  source_tmp_file="$(mktemp)"

  awk '
    BEGIN {
      updated = 0
    }
    /oh-my-zsh\.sh/ && updated == 0 {
      print "plugins=(git)"
      updated = 1
    }
    {
      print
    }
    END {
      if (updated == 0) {
        exit 1
      }
    }
  ' "${zshrc_path}" > "${source_tmp_file}"

  mv "${source_tmp_file}" "${zshrc_path}"
  echo "Enabled Oh My Zsh git plugin"
}

ensure_genesis_zshrc_block() {
  local zshrc_path="$1"
  local start_marker="# >>> genesis >>>"
  local end_marker="# <<< genesis <<<"

  echo "Updating ${zshrc_path}..."
  local tmp_file
  tmp_file="$(mktemp)"

  awk -v start="${start_marker}" -v end="${end_marker}" '
    BEGIN {
      in_block = 0
    }
    index($0, start) == 1 {
      in_block = 1
      next
    }
    index($0, end) == 1 {
      in_block = 0
      next
    }
    in_block == 0 {
      print
    }
  ' "${zshrc_path}" > "${tmp_file}"

  cat <<EOF >> "${tmp_file}"

${start_marker}
# Quiet, NPM
export DISABLE_OPENCOLLECTIVE=1
export ADBLOCK=1

# NVM
export NVM_DIR="\$HOME/.nvm"
[[ -s "\$NVM_DIR/nvm.sh" ]] && \. "\$NVM_DIR/nvm.sh"
[[ -s "\$NVM_DIR/bash_completion" ]] && \. "\$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="\$HOME/Library/pnpm"
case ":\$PATH:" in
  *":\$PNPM_HOME:"*) ;;
  *) export PATH="\$PNPM_HOME:\$PATH" ;;
esac

# bun
export BUN_INSTALL="\$HOME/.bun"
case ":\$PATH:" in
  *":\$BUN_INSTALL/bin:"*) ;;
  *) export PATH="\$BUN_INSTALL/bin:\$PATH" ;;
esac
[[ -s "\$HOME/.bun/_bun" ]] && source "\$HOME/.bun/_bun"

# Local tools
export PATH="\$HOME/.local/bin:\$PATH"

# Common aliases
alias ip="ipconfig getifaddr en0"
alias zshconfig="nvim ~/.zshrc"
alias zshsource="source ~/.zshrc"
alias sshhome="cd ~/.ssh"
alias sshconfig="nvim ~/.ssh/config"
alias gitconfig="nvim ~/.gitconfig"
alias c="cursor"
alias gits="git status"
alias gitd="git diff"
alias gitl="git lg"
alias gita="git add ."
alias lfg="codex --yolo"
alias code="cursor"

# Faster directory navigation
setopt autocd
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'
alias ......='../../../../..'

# Optional tool initialization
command -v starship >/dev/null 2>&1 && eval "\$(starship init zsh)"

# Machine-local overrides and secrets
[[ -f "\$HOME/.zshrc.local" ]] && source "\$HOME/.zshrc.local"
${end_marker}
EOF

  mv "${tmp_file}" "${zshrc_path}"
}

configure_zshrc() {
  local zshrc_path="${HOME}/.zshrc"

  touch "${zshrc_path}"
  ensure_oh_my_zsh_git_plugin "${zshrc_path}"
  ensure_genesis_zshrc_block "${zshrc_path}"
}
