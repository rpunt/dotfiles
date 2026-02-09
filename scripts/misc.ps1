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

function prlist {
  $(az repos pr list) | ConvertFrom-Json | Select-Object @{Name='ID'; Expression={$_.pullRequestId}}, @{Name='Title'; Expression={$_.title}} | Format-Table
}

function prbrowse {
  $currentBranch = git branch --show-current
  $prs = $(az repos pr list --source-branch $currentBranch) | ConvertFrom-Json
  if ($prs.Count -gt 0) {
    $pr = $prs[0]
    az repos pr show --id $pr.pullRequestId --open | Out-Null
  }
  else {
    Write-Host "No PR found for branch: $currentBranch"
  }
}
