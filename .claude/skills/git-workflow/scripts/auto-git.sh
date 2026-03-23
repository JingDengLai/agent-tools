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

# ========= 检测远程仓库类型 (GitHub / GitLab / Other) =========
REMOTE_URL=$(git remote get-url origin)
REPO_TYPE=""
WEB_URL=""

if [[ "$REMOTE_URL" == *"github.com"* ]] || [[ "$REMOTE_URL" == *"github"* ]]; then
  REPO_TYPE="github"
elif [[ "$REMOTE_URL" == *"gitlab.com"* ]] || [[ "$REMOTE_URL" == *"gitlab"* ]]; then
  REPO_TYPE="gitlab"
else
  REPO_TYPE="other"
fi

echo "👉 检测到远程仓库类型：$REPO_TYPE"

# ========= 生成 branch =========
# 处理分支名：转小写、中文转英文、空格变连字符、只保留字母数字和连字符
BRANCH_NAME=$(echo "$TASK_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | \
  sed 's/实现/implement/g' | \
  sed 's/添加/add/g' | \
  sed 's/创建/create/g' | \
  sed 's/登录/login/g' | \
  sed 's/注册/register/g' | \
  sed 's/页面/page/g' | \
  sed 's/功能/feature/g' | \
  sed 's/修复/fix/g; s/bug/fix/g' | \
  sed 's/用户/user/g' | \
  sed 's/个人/profile/g' | \
  sed 's/中心/center/g' | \
  sed 's/编写/write/g' | \
  sed 's/使用教程/usage-guide/g' | \
  sed 's/测试/test/g' | \
  sed 's/新增/new/g' | \
  sed 's/完善/improve/g' | \
  sed 's/文档/doc/g' | \
  sed 's/-*feature//g' | \
  tr -cd 'a-z0-9-' | \
  sed 's/^-//; s/-$//' | \
  cut -c1-30)

# 如果分支名为空（没有匹配到翻译），使用时间戳
if [ -z "$BRANCH_NAME" ]; then
  BRANCH_NAME="task-$(date +%Y%m%d%H%M%S)"
fi

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
  echo "完成后再次运行以提交和创建 MR/PR："
  echo "  bash scripts/auto-git.sh \"$TASK_DESC\" --commit"
  exit 0
fi

# ========= 模式 2: 提交并创建 MR/PR（开发后） =========
echo "👉 切换到分支：$BRANCH"
if git show-ref --verify --quiet refs/heads/$BRANCH; then
  git checkout $BRANCH
else
  echo "⚠️ 分支 $BRANCH 不存在，先创建分支"
  git checkout -b $BRANCH
fi

# ========= 检查是否有改动（包括 untracked 文件）========
HAS_CHANGES=false

# 检查 staged 改动
if ! git diff --cached --quiet; then
  HAS_CHANGES=true
fi

# 检查 unstaged 改动
if ! git diff --quiet; then
  HAS_CHANGES=true
fi

# 检查 untracked 文件
if [ -n "$(git ls-files --others --exclude-standard)" ]; then
  HAS_CHANGES=true
fi

if [ "$HAS_CHANGES" = false ]; then
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

# ========= 创建 MR/PR =========
echo "👉 检查 MR/PR 创建能力..."

if [ "$REPO_TYPE" = "github" ]; then
  # GitHub: 使用 gh CLI
  if ! command -v gh &> /dev/null; then
    echo "⚠️ 未安装 GitHub CLI (gh)，跳过 PR 创建"
    echo "👉 请手动创建 PR 或访问：https://github.com 新建 Pull Request"
    echo ""
    echo "📝 PR 信息："
    echo "   标题：$PREFIX: $TASK_DESC"
    echo "   分支：$BRANCH -> main"
    echo ""
    echo "✅ 代码已推送！"
    exit 0
  fi

  if ! gh auth status &> /dev/null; then
    echo "⚠️ 未登录 GitHub CLI，跳过 PR 创建"
    echo "👉 请执行：gh auth login"
    echo ""
    echo "✅ 代码已推送！"
    exit 0
  fi

  if ! gh repo view &> /dev/null; then
    echo "⚠️ 无法访问 GitHub 仓库，跳过 PR 创建"
    echo "👉 请手动访问 GitHub 创建 PR"
    echo ""
    echo "✅ 代码已推送！"
    exit 0
  fi

  # 检查 PR 是否已存在
  EXISTING_PR=$(gh pr list --head $BRANCH --state open --json number --jq '.[0].number')

  if [ -n "$EXISTING_PR" ]; then
    echo "⚠️ PR 已存在：$(gh repo view --json url --jq .url)/pull/$EXISTING_PR"
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

elif [ "$REPO_TYPE" = "gitlab" ]; then
  # GitLab: 使用 glab CLI 或提供手动指引
  if command -v glab &> /dev/null && glab auth status &> /dev/null; then
    echo "👉 使用 glab 创建 MR..."

    # 检查 MR 是否已存在
    EXISTING_MR=$(glab mr list --source-branch $BRANCH --state opened --json iid --jq '.[0].iid' 2>/dev/null)

    if [ -n "$EXISTING_MR" ]; then
      echo "⚠️ MR 已存在"
    else
      glab mr create \
        --title "$PREFIX: $TASK_DESC" \
        --description "## 变更内容
- $TASK_DESC

## 测试方式
- 手动验证功能
" \
        --target-branch main \
        --source-branch $BRANCH
    fi
  else
    echo "⚠️ 未安装或未登录 GitLab CLI (glab)，跳过 MR 创建"
    echo "👉 安装 glab: https://gitlab.com/gitlab-org/cli"
    echo ""
    echo "📝 请手动创建 MR："
    REMOTE_WEB=$(echo "$REMOTE_URL" | sed 's/git@\(.*\):\(.*\)\.git/https:\/\/\1\/\2/' | sed 's/\.git$//')
    echo "   访问：$REMOTE_WEB/merge_requests/new?merge_request[source_branch]=$BRANCH"
    echo ""
    echo "📝 MR 信息："
    echo "   标题：$PREFIX: $TASK_DESC"
    echo "   分支：$BRANCH -> main"
    echo ""
  fi

else
  # 其他 Git 服务
  echo "⚠️ 未知远程仓库类型，跳过 MR/PR 创建"
  echo ""
  echo "📝 请手动创建 MR/PR："
  echo "   分支：$BRANCH -> main"
  echo "   标题：$PREFIX: $TASK_DESC"
  echo ""
fi

echo "✅ 完成！🚀"
