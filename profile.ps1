$scripts = Get-ChildItem "${Env:HOMEDRIVE}${Env:HOMEPATH}/dev/dotfiles/scripts/" -Filter "*.ps1"
foreach ($script in $scripts) {
  . "${Env:HOMEDRIVE}${Env:HOMEPATH}/dev/dotfiles/scripts/$script"
}
