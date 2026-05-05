# dotfiles

Personal dotfile supplements

## Usage

### Bash or ZSH

```bash
git clone https://github.com/rpunt/dotfiles.git; cd dotfiles

brew bundle install

echo "source ${PWD}/bashrc" >~/.bashrc
echo "source ${PWD}/zshrc" >~/.zshrc
```

You can place any environment- or computer-specific overrides in `~/.local_profile_overrides` - they'll be sourced last.

### Powershell

```powershell
$symlinkParams = @{
  Path = $PROFILE
  Value = "${PWD}/profile.ps1"
  ItemType = 'SymbolicLink'
  Force = $true
}
New-Item @symlinkParams

. $PROFILE
```

Close all terminals, and any new terminals will reflect the settings in this repo

## Configuration

Optional variables can be set in `~/.dotfiles_config` (sourced early, before everything else):

| Variable | Default | Description |
| --- | --- | --- |
| `SCM_PROVIDER` | `github` | Set to `ado` to load Azure DevOps helpers instead of GitHub helpers |
| `GIT_AUTH_PAT` | `false` | Set to `true` to enable PAT-based git authentication (prompts for a PAT on first git operation and injects it as an HTTP header) |

## Package Specifics

### Oh-my-posh

#### Install Oh-My-Posh

```bash
brew tap jandedobbeleer/oh-my-posh
brew install oh-my-posh
```

#### Install powerline font

Recommended font: [Caskaydia Cove Nerd Font Complete](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha)

Set your terminal to use the above font for full glyph compatibility.

### 1password.sh

Functions for [1password-cli](https://1password.com/downloads/command-line/)

* [Getting started guide](https://support.1password.com/command-line-getting-started/)
