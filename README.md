# dotfiles

Personal dotfile supplements

## Usage

```bash
git clone https://github.com/rpunt/dotfiles.git
echo -e "for file in \$(ls $(echo ${PWD})/dotfiles/scripts/*.sh); do\n  source \$file\ndone" >>~/.bashrc
. ~/.bashrc
```

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
