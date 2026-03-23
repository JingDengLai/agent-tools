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

## Git WorkFlow

自动化的 Git 工作流工具，支持**先创建分支再开发**的标准流程。

### 使用方法

#### 第一步：创建分支（开发前）

```bash
bash scripts/auto-git.sh "任务描述"
```

这会：
- 自动创建功能分支（如 `feature/任务描述`）
- 切换到新分支
- 提示你开始编写代码

#### 第二步：编写代码

正常进行开发工作，创建或修改文件。

#### 第三步：提交并创建 PR（开发后）

```bash
bash scripts/auto-git.sh "任务描述" --commit
```

这会：
- 切换到对应分支
- 自动添加并提交所有改动
- 推送到远程仓库
- 创建 Pull Request

### 示例

```bash
# 1. 创建分支开始开发
bash scripts/auto-git.sh "实现用户登录功能"

# 2. ...编写代码...

# 3. 提交并创建 PR
bash scripts/auto-git.sh "实现用户登录功能" --commit
```

### 分支命名规则

| 任务类型 | 前缀 | 示例 |
|---------|------|------|
| 新功能 | `feature/` | `feature/login-page` |
| Bug 修复 | `fix/` | `fix/auth-error` |
| 重构 | `refactor/` | `refactor/user-module` |

脚本会自动根据任务描述判断类型（包含 "fix"、"修复"、"bug" 的会被识别为修复类型）。

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

## License

MIT
