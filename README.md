# Agent Tools

自动化 Git 工作流工具集，帮助开发者快速完成标准化的开发流程。

## 快速开始

### 环境要求

- Git
- GitHub CLI (gh)
- 已登录 GitHub：`gh auth login`

### 安装 gh CLI

**Windows:**
```bash
winget install GitHub.cli
```

**macOS:**
```bash
brew install gh
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt install gh

# RHEL/CentOS
sudo dnf install gh
```

### 登录 GitHub

```bash
gh auth login
```

---

## 完整使用流程

### 流程概览

```
给 AI 提示词 → 创建分支 → 开发编码 → 提交代码 → 创建 PR → 完成
```

### 详细步骤

#### 步骤 1：给 AI 提示词

告诉 AI 你要开发的功能，例如：

```
使用 html 实现一个登录页面
```

#### 步骤 2：AI 自动创建分支

AI 会自动执行 git-workflow，创建功能分支：

```bash
bash scripts/auto-git.sh "实现登录页面"
```

输出：
```
👉 创建新分支：feature/implement-login
Switched to a new branch 'feature/implement-login'

✅ 分支已就绪：feature/implement-login
📝 请开始编写代码...
```

#### 步骤 3：AI 开发编码

AI 在分支上编写代码，创建所需文件：

```
├── login.html          # 登录页面
```

#### 步骤 4：提交代码并创建 PR

AI 完成开发后，自动执行：

```bash
bash scripts/auto-git.sh "实现登录页面" --commit
```

输出：
```
👉 提交代码
[feature/implement-login a1b2c3d] feature: 实现登录页面
  1 file changed, 200 insertions(+)
  create mode 100644 login.html

👉 推送远程
👉 创建 PR...
https://github.com/your-repo/pull/1

✅ 完成！🚀
```

#### 步骤 5：Review 并合并 PR

1. 访问 GitHub 查看 PR
2. 检查代码变更
3. 点击 **Merge pull request**
4. 确认合并

---

## Git WorkFlow 命令参考

### 第一阶段：创建分支（开发前）

```bash
bash scripts/auto-git.sh "任务描述"
```

这会：
- 自动创建功能分支（如 `feature/task-name`）
- 切换到新分支
- 提示你开始编写代码

### 第二阶段：提交并创建 PR（开发后）

```bash
bash scripts/auto-git.sh "任务描述" --commit
```

这会：
- 切换到对应分支
- 自动添加并提交所有改动
- 推送到远程仓库
- 创建 Pull Request

### 分支命名规则

| 任务类型 | 前缀 | 示例 |
|---------|------|------|
| 新功能 | `feature/` | `feature/login-page` |
| Bug 修复 | `fix/` | `fix/auth-error` |
| 重构 | `refactor/` | `refactor/user-module` |

脚本会自动根据任务描述判断类型（包含 "fix"、"修复"、"bug" 的会被识别为修复类型）。

### 中文任务描述自动翻译

| 中文 | 英文分支名 |
|------|-----------|
| 实现登录页面 | `feature/implement-login-page` |
| 测试新增功能 | `feature/test-new-feature` |
| 修复用户 bug | `fix/user-bug` |

---

## 项目结构

```
.
├── .claude/
│   └── skills/
│       └── git-workflow/
│           ├── scripts/
│           │   └── auto-git.sh    # Git 工作流脚本
│           ├── SKILL.md           # Skill 定义
│           └── examples.md        # 使用示例
├── README.md
└── CLAUDE.md                      # Claude 配置
```

---

## 常见问题

### Q: 提示 "未检测到 GitHub CLI"
A: 请先安装 gh：`brew install gh` 或访问 https://cli.github.com

### Q: 提示 "未登录 GitHub CLI"
A: 请执行登录：`gh auth login`

### Q: 分支名包含中文怎么办？
A: 脚本会自动将常见中文词汇翻译成英文，如"登录"→"login"

### Q: 可以自定义分支命名规则吗？
A: 可以编辑 `scripts/auto-git.sh` 中的翻译规则

---

## License

MIT
