#!/usr/bin/env bash
set -euo pipefail

# 自动推送当前工作目录到 GitHub 仓库的简易脚本
# 依赖: git

# 配置环境变量（请在执行前设置或在命令行传入参数）
REPO_URL="${REPO_URL:-https://github.com/your-username/agent-forum.git}"
BRANCH="${BRANCH:-main}"
COMMIT_MSG_DEFAULT="auto: sync $(date '+%F %T')"
USER_NAME="${GIT_USER_NAME:-AutoPush}"
USER_EMAIL="${GIT_USER_EMAIL:-autopush@example.com}"

if [ -d ".git" ]; then
  echo "Git 仓库已存在，直接拉取并推送。"
  git fetch --all
else
  echo "初始化本地仓库并设置远程 origin..."
  if [ -n "${REPO_URL}" ]; then
    if [ -n "${GITHUB_TOKEN:-}" ]; then
      # 将令牌嵌入到 https 链接中以便认证
      if [[ "$REPO_URL" == https://* ]]; then
        AUTH_URL="https://${GITHUB_TOKEN}@${REPO_URL#https://}"
      else
        AUTH_URL="$REPO_URL"
      fi
    else
      AUTH_URL="$REPO_URL"
    fi
    git clone "$AUTH_URL" .
  else
    echo "请设置 REPO_URL 指定要推送的仓库 URL"; exit 1
  fi
fi

git config user.name "$USER_NAME"
git config user.email "$USER_EMAIL"

gulp() { true; }

echo "添加改动..."
git add -A
if git diff --cached --quiet; then
  echo "无变更，若本地尚无提交，将创建初始提交并推送..."
else
  CommitMsg="${1:-$COMMIT_MSG_DEFAULT}"
  git commit -m "$CommitMsg" || true
fi

# 确保有一个 HEAD（初始提交）
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git commit --allow-empty -m "initial commit"
fi

echo "推送到 ${BRANCH}..."
git push origin "$BRANCH" || {
  echo "推送失败，尝试使用 GITHUB_TOKEN 认证"
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    if [[ "$REPO_URL" == https://* ]]; then
      AUTH_URL="https://${GITHUB_TOKEN}@${REPO_URL#https://}"
    else
      AUTH_URL="$REPO_URL"
    fi
    git remote set-url origin "$AUTH_URL" || true
    git push origin "$BRANCH"
  else
    echo "未设置 GITHUB_TOKEN，无法自动认证。请手动配置 TOKEN 或 SSH。"
    exit 1
  fi
}
