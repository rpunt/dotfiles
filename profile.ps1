function mktemp {
  param (
    [Parameter(mandatory = $false)]$Extension
  )
  $randomfile = [System.IO.Path]::GetRandomFileName()
  if ($Extension) {
    $randomfile = [System.IO.Path]::ChangeExtension($randomfile, $Extension)
  }
  return Microsoft.PowerShell.Management\Join-Path ([System.IO.Path]::GetTempPath()) "$randomfile"
}

# this assumes you've already cloned the dotfiles repo
oh-my-posh init pwsh --config "${Env:HOMEDRIVE}${Env:HOMEPATH}\dev\dotfiles\rpunt.omp.json" | Invoke-Expression
