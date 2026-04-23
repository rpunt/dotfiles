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
