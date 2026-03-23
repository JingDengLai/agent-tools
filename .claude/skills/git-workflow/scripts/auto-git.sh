#!/bin/bash

# ========= 参数 =========
TASK_DESC="$1"

if [ -z "$TASK_DESC" ]; then
  echo "❌ 请提供任务描述，例如："
  echo "bash scripts/auto-git.sh \"add partial refund support\""
  exit 1
fi

# ========= 检查 gh CLI =========
if ! command -v gh &> /dev/null; then
  echo "❌ 未检测到 GitHub CLI (gh)"
  echo "👉 请先安装：brew install gh"
  exit 1
fi

# ========= 检查 gh 登录状态 =========
if ! gh auth status &> /dev/null; then
  echo "❌ 未登录 GitHub CLI"
  echo "👉 请执行登录：gh auth login"
  exit 1
fi

# ========= 检查是否在 git 仓库 =========
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "❌ 当前目录不是 Git 仓库"
  exit 1
fi

# ========= 检查 remote =========
if ! git remote get-url origin &> /dev/null; then
  echo "❌ 未配置远程仓库 origin"
  echo "👉 请先执行：git remote add origin <repo-url>"
  exit 1
fi

# ========= 检查是否有改动 =========
if git diff --cached --quiet && git diff --quiet; then
  echo "⚠️ 没有检测到代码改动，跳过提交"
  exit 1
fi

# ========= 生成 branch =========
BRANCH_NAME=$(echo "$TASK_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | cut -c1-30)

# 自动判断类型
if [[ "$TASK_DESC" == *fix* ]]; then
  PREFIX="fix"
else
  PREFIX="feature"
fi

BRANCH="$PREFIX/$BRANCH_NAME"

echo "👉 创建分支: $BRANCH"
git checkout -b $BRANCH

# ========= 提交 =========
echo "👉 提交代码"
git add .
git commit -m "feat: $TASK_DESC"

# ========= 推送 =========
echo "👉 推送远程"
git push origin $BRANCH

# ========= 创建 PR =========
echo "👉 检查 PR 创建能力..."

if ! gh repo view &> /dev/null; then
  echo "❌ 无法访问 GitHub 仓库"
  echo "👉 请检查："
  echo "   1. 当前仓库是否在 GitHub"
  echo "   2. 是否有权限访问该仓库"
  exit 1
fi

echo "👉 创建 PR..."
gh pr create \
  --title "$TASK_DESC" \
  --body "## 变更内容
- $TASK_DESC

## 测试方式
- 手动验证功能
" \
  --base main \
  --head $BRANCH

echo "✅ PR 已成功创建 🚀"