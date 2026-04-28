# this assumes you've already cloned the dotfiles repo, and assumes the clone path
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  if ($PSVersionTable.os -match "Darwin") {
    # oh-my-posh init pwsh --config "${env:HOME}/dev/dotfiles/rpunt.omp.json" | Invoke-Expression
    # $(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
    $env:POSH_THEMES_PATH = Join-Path -Path "$(brew --prefix oh-my-posh)" -ChildPath themes
    [scriptblock]::Create($(oh-my-posh completion powershell)).Invoke()
    oh-my-posh init pwsh --config "${env:HOME}/dev/dotfiles/rpunt.omp.json" | iex
  }

  if ($PSVersionTable.os -match "Windows") {
    oh-my-posh init pwsh --config "${Env:HOMEDRIVE}${Env:HOMEPATH}\dev\dotfiles\rpunt.omp.json" | Invoke-Expression
  }

  # alternate for Windows, from https://gist.github.com/rkttu/3d286f711ebd7de239489fc3310a80cd
  # for PowerShell (Windows)
  if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
    # $env:POSH_THEMES_PATH = Join-Path -Path (Get-Item -Path (Get-Command -Name 'oh-my-posh').Source).Directory.Parent.FullName -ChildPath 'themes'
    # [scriptblock]::Create($(oh-my-posh completion powershell)).Invoke()
    # oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/clean-detailed.omp.json" | iex
    oh-my-posh init pwsh --config "${Env:HOMEDRIVE}${Env:HOMEPATH}\dev\dotfiles\rpunt.omp.json" | Invoke-Expression
  }
} else {
  function Get-GitInfo {
    try {
      $branch = git rev-parse --abbrev-ref HEAD 2>$null
      if (-not $branch) { return $null }

      $status = git status --porcelain 2>$null
      $dirty = if ($status) { "*" } else { "" }

      return @{
        Branch = $branch.Trim()
        Dirty  = $dirty
      }
    }
    catch {
      return $null
    }
  }

  function prompt {
    # $ok = $?

    # $time = Get-Date -Format "HH:mm:ss"
    $path = (Get-Location).Path.Replace($HOME, "~")
    $git = Get-GitInfo

    # $statusText = if ($ok) { "[OK]" } else { "[ERR]" }
    # $statusColor = if ($ok) { "Green" } else { "Red" }

    # Write-Host "+--------------------------------------------------" -ForegroundColor DarkGray

    # Write-Host "|" -NoNewline -ForegroundColor DarkGray
    # Write-Host " $time " -NoNewline -ForegroundColor Yellow
    Write-Host "$path" -NoNewline -ForegroundColor Cyan

    if ($git) {
      Write-Host "  git:" -NoNewline -ForegroundColor DarkGray
      Write-Host " $($git.Branch)$($git.Dirty)" -NoNewline -ForegroundColor Magenta
    }

    Write-Host ""

    # Write-Host "|" -NoNewline -ForegroundColor DarkGray
    # Write-Host " $path" -ForegroundColor Cyan

    # Write-Host "+--------------------------------------------------" -ForegroundColor DarkGray
    return "> "
  }
}
