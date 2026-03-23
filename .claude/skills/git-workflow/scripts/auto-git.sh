#!/bin/bash

# ========= 参数 =========
TASK_DESC="$1"
MODE="$2"

if [ -z "$TASK_DESC" ]; then
  echo "❌ 请提供任务描述，例如："
  echo "bash scripts/auto-git.sh \"add login page\""
  echo ""
  echo "或者分阶段执行："
  echo "  1. 创建分支：bash scripts/auto-git.sh \"add login page\""
  echo "  2. 提交代码：bash scripts/auto-git.sh \"add login page\" --commit"
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

# ========= 生成 branch =========
BRANCH_NAME=$(echo "$TASK_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | cut -c1-30)

# 自动判断类型
if [[ "$TASK_DESC" == *"fix"* ]] || [[ "$TASK_DESC" == *"修复"* ]] || [[ "$TASK_DESC" == *"bug"* ]]; then
  PREFIX="fix"
else
  PREFIX="feature"
fi

BRANCH="$PREFIX/$BRANCH_NAME"

# ========= 模式 1: 仅创建/切换分支（开发前） =========
if [ "$MODE" != "--commit" ]; then
  # 检查分支是否存在
  if git show-ref --verify --quiet refs/heads/$BRANCH; then
    echo "👉 切换到现有分支：$BRANCH"
    git checkout $BRANCH
  else
    echo "👉 创建新分支：$BRANCH"
    git checkout -b $BRANCH
  fi

  echo ""
  echo "✅ 分支已就绪：$BRANCH"
  echo "📝 请开始编写代码..."
  echo ""
  echo "完成后再次运行以提交和创建 PR："
  echo "  bash scripts/auto-git.sh \"$TASK_DESC\" --commit"
  exit 0
fi

# ========= 模式 2: 提交并创建 PR（开发后） =========
echo "👉 切换到分支：$BRANCH"
if git show-ref --verify --quiet refs/heads/$BRANCH; then
  git checkout $BRANCH
else
  echo "⚠️ 分支 $BRANCH 不存在，先创建分支"
  git checkout -b $BRANCH
fi

# ========= 检查是否有改动 =========
if git diff --cached --quiet && git diff --quiet; then
  echo "⚠️ 没有检测到代码改动，跳过提交"
else
  # ========= 提交 =========
  echo "👉 提交代码"
  git add .
  git commit -m "$PREFIX: $TASK_DESC"

  # ========= 推送 =========
  echo "👉 推送远程"
  git push -u origin $BRANCH
fi

# ========= 创建 PR =========
echo "👉 检查 PR 创建能力..."

if ! gh repo view &> /dev/null; then
  echo "❌ 无法访问 GitHub 仓库"
  echo "👉 请检查："
  echo "   1. 当前仓库是否在 GitHub"
  echo "   2. 是否有权限访问该仓库"
  exit 1
fi

# 检查 PR 是否已存在
EXISTING_PR=$(gh pr list --head $BRANCH --state open --json number --jq '.[0].number')

if [ -n "$EXISTING_PR" ]; then
  echo "⚠️ PR 已存在：https://github.com/$(gh repo view --json nameWithOwner --jq .nameWithOwner)/pull/$EXISTING_PR"
else
  echo "👉 创建 PR..."
  gh pr create \
    --title "$PREFIX: $TASK_DESC" \
    --body "## 变更内容
- $TASK_DESC

## 测试方式
- 手动验证功能
" \
    --base main \
    --head $BRANCH
fi

echo "✅ 完成！🚀"
