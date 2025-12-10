# macOS-specific tweaks

# Example: use gnu coreutils if installed
if command -v gls >/dev/null 2>&1; then
  alias ls='gls --color=auto'
fi

# if os = MacOS
export SSH_AUTH_SOCK="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
# don't forget these also:
# launchctl stop com.openssh.ssh-agent
# launchctl disable com.openssh.ssh-agent
