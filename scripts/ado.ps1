function azpr {
  $output = az repos pr create --auto-complete --delete-source-branch @args 2>&1
  if ($LASTEXITCODE -ne 0) {
    $currentBranch = git branch --show-current
    $existing = az repos pr list --source-branch $currentBranch | ConvertFrom-Json
    if ($existing.Count -gt 0) {
      $pr = az repos pr show --id $existing[0].pullRequestId | ConvertFrom-Json
      $url = "$($pr.repository.webUrl)/pullrequest/$($pr.pullRequestId)"
      $url | Set-Clipboard
      Write-Host "PR #$($pr.pullRequestId) already exists. URL copied to clipboard:" -ForegroundColor Yellow
      Write-Host $url
      return
    }
    Write-Host "Failed to create PR:" -ForegroundColor Red
    Write-Host ($output -join "`n") -ForegroundColor Red
    return
  }
  $pr = $output | ConvertFrom-Json
  $url = "$($pr.repository.webUrl)/pullrequest/$($pr.pullRequestId)"

  $url | Set-Clipboard
  Write-Host "PR #$($pr.pullRequestId) created. URL copied to clipboard:" -ForegroundColor Green
  Write-Host $url
}

function prlist {
  $prs = az repos pr list | ConvertFrom-Json
  if (-not $prs -or $prs.Count -eq 0) {
    Write-Host "No open PRs found." -ForegroundColor Yellow
    return
  }
  $prs | Select-Object `
    @{Name = 'ID'; Expression = { $_.pullRequestId } }, `
    @{Name = 'Title'; Expression = { $_.title } }, `
    @{Name = 'Author'; Expression = { $_.createdBy.displayName } }, `
    @{Name = 'Branch'; Expression = { ($_.sourceRefName -replace '^refs/heads/', '') + ' -> ' + ($_.targetRefName -replace '^refs/heads/', '') } }, `
    @{Name = 'Draft'; Expression = { if ($_.isDraft) { 'yes' } else { '' } } } |
    Format-Table -AutoSize
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
  $policiesJson = az repos pr policy list --id $PullRequestId
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to retrieve policy checks for PR #$PullRequestId."
  }
  $policies = $policiesJson | ConvertFrom-Json
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

  $target = $pr.targetRefName -replace '^refs/heads/', ''
  $source = $pr.sourceRefName -replace '^refs/heads/', ''

  Write-Host ""
  Write-Host "PR #$PullRequestId" -ForegroundColor Cyan -NoNewline
  Write-Host "  $($pr.title)"
  Write-Host "  Author: $($pr.createdBy.displayName)"
  Write-Host "  Repo:   $($pr.repository.name)"
  Write-Host "  Branch: $source -> $target"
  if ($pr.isDraft) { Write-Host "  Draft:  yes" -ForegroundColor Yellow }
  if ($pr.description) {
    Write-Host "  Description:"
    $pr.description -split "`n" | ForEach-Object { Write-Host "    $_" }
  }
  $reviewerNames = @($pr.reviewers | ForEach-Object { $_.displayName })
  if ($reviewerNames.Count -gt 0) {
    Write-Host "  Reviewers: $($reviewerNames -join ', ')"
  }
  Write-Host ""

  $showDiff = (Read-Host "Do you want to see the diff? (y/n)").ToLower()
  if ($showDiff -eq 'y') {
    git diff "origin/$target...origin/$source"
  }

  $approve = (Read-Host "Do you approve PR ${PullRequestId}? (y/n/s for skip)").ToLower()
  if ($approve -eq 'y') {
    Write-Host "Approving PR #$PullRequestId..." -ForegroundColor Cyan
    az repos pr set-vote --id $PullRequestId --vote approve | Out-Null
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
    Write-Host "Opening PR #$($pr.pullRequestId) in browser..." -ForegroundColor Cyan
    az repos pr show --id $pr.pullRequestId --open | Out-Null
  }
  else {
    Write-Host "No PR found for branch: $currentBranch" -ForegroundColor Yellow
  }
}
