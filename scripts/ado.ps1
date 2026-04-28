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

function check_pr_approved {
  param([Parameter(Mandatory)][int]$PullRequestId)
  $reviewers = az repos pr reviewer list --id $PullRequestId | ConvertFrom-Json
  @($reviewers | Where-Object { $_.vote -eq 10 }).Count
}

function check_pr_approvers {
  param([Parameter(Mandatory)][int]$PullRequestId)
  $reviewers = az repos pr reviewer list --id $PullRequestId | ConvertFrom-Json
  $reviewers | Where-Object { $_.vote -eq 10 } | ForEach-Object { $_.displayName }
}

function check_pr_checks {
  param([Parameter(Mandatory)][int]$PullRequestId)
  $policies = az repos pr policy list --id $PullRequestId | ConvertFrom-Json
  $failed = @($policies | Where-Object { $_.isBlocking -and $_.status -ne 'approved' })
  return ($failed.Count -eq 0)
}

function check_pr_failed_checks {
  param([Parameter(Mandatory)][int]$PullRequestId)
  $policies = az repos pr policy list --id $PullRequestId | ConvertFrom-Json
  $policies | Where-Object { $_.status -ne 'approved' } | ForEach-Object {
    [PSCustomObject]@{
      Policy = $_.configuration.type.displayName
      Status = $_.status
    }
  }
}

function check_pr_merge_state {
  param([Parameter(Mandatory)][int]$PullRequestId)
  $pr = az repos pr show --id $PullRequestId | ConvertFrom-Json
  $pr.mergeStatus
}

function check_pr_is_merged {
  param([Parameter(Mandatory)][int]$PullRequestId)
  $pr = az repos pr show --id $PullRequestId | ConvertFrom-Json
  $pr.status
}

function review_pr {
  param([Parameter(Mandatory)][int]$PullRequestId)

  $pr = az repos pr show --id $PullRequestId | ConvertFrom-Json
  if (-not $pr) {
    Write-Host "Error: PR #$PullRequestId not found" -ForegroundColor Red
    return
  }

  $approved = check_pr_approved $PullRequestId
  if ($approved -gt 0) {
    Write-Host "PR $PullRequestId is already approved by $approved reviewer(s), skipping." -ForegroundColor Yellow
    return
  }

  Write-Host "Reviewing PR #$PullRequestId by $($pr.createdBy.displayName): $($pr.title)" -ForegroundColor Cyan
  az repos pr show --id $PullRequestId

  $showDiff = (Read-Host "Do you want to see the diff? (y/n)").ToLower()
  if ($showDiff -eq 'y') {
    $target = $pr.targetRefName -replace '^refs/heads/', ''
    $source = $pr.sourceRefName -replace '^refs/heads/', ''
    git diff "origin/$target...origin/$source"
  }

  $approve = (Read-Host "Do you approve PR ${PullRequestId}? (y/n/s for skip)").ToLower()
  if ($approve -eq 'y') {
    Write-Host "Approving PR #$PullRequestId..." -ForegroundColor Cyan
    az repos pr set-vote --id $PullRequestId --vote approve
    Write-Host "PR #$PullRequestId approved!" -ForegroundColor Green
  }
  elseif ($approve -eq 's') {
    Write-Host "Skipping PR #$PullRequestId" -ForegroundColor Yellow
  }
  else {
    Write-Host "PR #$PullRequestId not approved" -ForegroundColor Red
  }
}

function approve_list {
  param([Parameter(Mandatory)][string]$SourceFile)

  if (-not (Test-Path $SourceFile)) {
    Write-Host "Error: File '$SourceFile' not found" -ForegroundColor Red
    return
  }

  Write-Host "Processing PRs from $SourceFile..." -ForegroundColor Cyan
  Get-Content $SourceFile | ForEach-Object {
    $number = [regex]::Match($_, '\d+').Value
    if ($number) {
      review_pr -PullRequestId ([int]$number)
    }
  }
  Write-Host "All PRs from $SourceFile processed!" -ForegroundColor Green
}

function approve_for {
  param([Parameter(Mandatory)][string]$Username)

  $creator = switch ($Username) {
    'shamer' { 'shamer-dd' }
    'rpunt' { 'dd-rpunt' }
    'jloar' { 'dd-jloar' }
    'bkwon' { 'bryankwon-doordash' }
    default {
      Write-Host "Unknown user: $Username" -ForegroundColor Red
      return
    }
  }

  $prs = az repos pr list --creator $creator | ConvertFrom-Json
  $prs | Where-Object { -not $_.isDraft } | ForEach-Object {
    review_pr -PullRequestId $_.pullRequestId
  }
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
