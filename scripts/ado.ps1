function azpr {
  $pr = az repos pr create --auto-complete --delete-source-branch @args | ConvertFrom-Json
  $url = "$($pr.repository.webUrl)/pullrequest/$($pr.pullRequestId)"

  $url | Set-Clipboard
  Write-Host "PR URL copied to clipboard:"
  $url
}

function prlist {
  $(az repos pr list) | ConvertFrom-Json | Select-Object @{Name = 'ID'; Expression = { $_.pullRequestId } }, @{Name = 'Title'; Expression = { $_.title } } | Format-Table
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
