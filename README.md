# dotfiles
Personal dotfile supplements

### Usage
```bash
git clone https://github.com/rpunt/dotfiles.git
echo -e "for file in \$(ls $(echo ${PWD})/dotfiles/scripts/*.sh); do\n  source \$file\ndone" >>~/.bashrc
. ~/.bashrc
```

#### 1password.sh
Functions for [1password-cli](https://1password.com/downloads/command-line/)
* [Getting started guide](https://support.1password.com/command-line-getting-started/)
