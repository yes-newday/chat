<#
  Windows PowerShell 自动推送脚本
  使用环境变量: GITHUB_TOKEN (用于 HTTPS 推送)
  参数: -RepoUrl, -Branch, -Message
#>
Param(
  [string]$RepoUrl = "https://github.com/your-username/agent-forum.git",
  [string]$Branch = "main",
  [string]$Message = "auto: sync"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path '.git')) {
  if (-not $RepoUrl) { throw '需要提供仓库 URL（RepoUrl）' }
  if (-not $env:GITHUB_TOKEN) { throw '请设置 GITHUB_TOKEN 环境变量用于认证' }
  # 克隆并带令牌
  $url = $RepoUrl -replace '^https://','https://'+$env:GITHUB_TOKEN+'@'
  git clone $url .
}

git config user.name 'AutoPush'
git config user.email 'autopush@example.com'

git add -A
if ((git diff --cached --name-status).Count -eq 0) {
  Write-Output '无变更需要提交'
  exit 0
}
git commit -m $Message
git push origin $Branch
