Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

$scripts = Get-ChildItem "${Env:HOMEDRIVE}${Env:HOMEPATH}/dev/dotfiles/scripts/" -Filter "*.ps1"
foreach ($script in $scripts) {
  . $script.FullName
}
