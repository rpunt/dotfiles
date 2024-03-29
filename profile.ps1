$scripts = gci "${env:HOME}/dev/dotfiles/scripts/" -Filter "*.ps1"
foreach ($script in $scripts) {
  . $script
}
