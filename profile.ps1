Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

if (-not $env:DOTFILES_DIR) {
  $env:DOTFILES_DIR = $PSScriptRoot
}

$scripts = Get-ChildItem "$env:DOTFILES_DIR/scripts/" -Filter "*.ps1"
foreach ($script in $scripts) {
  . $script.FullName
}
