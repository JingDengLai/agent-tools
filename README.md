# Agent Tools

自动化 Git 工作流工具集，帮助开发者快速完成标准化的开发流程。

---

## 🤖 Agent 身份

本项目中的 AI Agent 被配置为**资深前端开发工程师**。

### 角色定位

- 精通多种前端开发语言和框架（Vue / React / TypeScript / HTML / CSS）
- 从禅道获取开发任务（待 MCP 对接）
- 通过 GitLab / GitHub 管理代码和 MR/PR
- 自动汇报进度和通知

### 技术栈

- Vue / React
- TypeScript
- HTML / CSS
- vue-xpc / vue-xmobile
- API 集成
- 前端工程化

### 核心原则

1. 优先保证代码可读性和可维护性
2. 避免过度设计
3. 小步提交（small PR）
4. 关注用户体验

### 目标

构建高质量、可维护、可扩展的前端系统

---

支持 **GitHub** 和 **GitLab** 平台。

---

## 快速开始

### 环境要求

- Git
- 远程仓库（GitHub / GitLab / 其他 Git 服务）

### 可选：安装 CLI 工具

#### GitHub CLI (gh)

```bash
# Windows
winget install GitHub.cli

# macOS
brew install gh

# Linux
sudo apt install gh  # Debian/Ubuntu
sudo dnf install gh  # RHEL/CentOS
```

登录 GitHub:
```bash
gh auth login
```

#### GitLab CLI (glab)

```bash
# macOS
brew install glab

# Linux
sudo apt install glab
```

登录 GitLab:
```bash
glab auth login
```

---

## 完整使用流程

### 流程概览

```
给 AI 提示词 → 创建分支 → 开发编码 → 提交代码 → 创建 MR/PR → 完成
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
👉 检测到远程仓库类型：github
👉 创建新分支：feature/implement-login
Switched to a new branch 'feature/implement-login'

✅ 分支已就绪：feature/implement-login
📝 请开始编写代码...
```

#### 步骤 3：AI 开发编码

AI 在分支上编写代码，创建所需文件。

#### 步骤 4：提交代码并创建 MR/PR

AI 完成开发后，自动执行：

```bash
bash scripts/auto-git.sh "实现登录页面" --commit
```

输出（GitHub）：
```
👉 提交代码
[feature/implement-login a1b2c3d] feature: 实现登录页面
  1 file changed, 200 insertions(+)

👉 推送远程
👉 创建 PR...
https://github.com/your-repo/pull/1

✅ 完成！🚀
```

输出（GitLab）：
```
👉 提交代码
[feature/implement-login a1b2c3d] feature: 实现登录页面

👉 推送远程
👉 创建 MR...
https://gitlab.com/your-repo/merge_requests/1

✅ 完成！🚀
```

> **注意**：如果未安装 CLI 工具，脚本会提供手动创建的链接和指引。

#### 步骤 5：Review 并合并 MR/PR

1. 访问仓库平台查看 MR/PR
2. 检查代码变更
3. 点击 **Merge** 按钮
4. 确认合并

---

## Git WorkFlow 命令参考

### 第一阶段：创建分支（开发前）

```bash
bash scripts/auto-git.sh "任务描述"
```

这会：
- 自动创建功能分支
- 切换到新分支
- 提示你开始编写代码

### 第二阶段：提交并创建 MR/PR（开发后）

```bash
bash scripts/auto-git.sh "任务描述" --commit
```

这会：
- 切换到对应分支
- 自动添加并提交所有改动
- 推送到远程仓库
- 创建 Merge Request / Pull Request

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
| 编写文档 | `feature/doc` |

---

## 平台支持

| 功能 | GitHub | GitLab | 其他 Git |
|------|--------|--------|---------|
| 创建分支 | ✅ | ✅ | ✅ |
| 提交代码 | ✅ | ✅ | ✅ |
| 推送远程 | ✅ | ✅ | ✅ |
| 自动创建 MR/PR | ✅ (gh) | ✅ (glab) | 手动 |

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
A: 这是可选的。脚本会自动推送代码，你可以手动在网页上创建 PR。

### Q: 使用 GitLab 怎么办？
A: 脚本会自动检测 GitLab 仓库，如有安装 glab 会自动创建 MR。

### Q: 分支名包含中文怎么办？
A: 脚本会自动将常见中文词汇翻译成英文，如"登录"→"login"。

### Q: 可以自定义分支命名规则吗？
A: 可以编辑 `scripts/auto-git.sh` 中的翻译规则。

### Q: 远程仓库不是 GitHub 或 GitLab？
A: 脚本依然可以创建分支和提交代码，MR/PR 需要手动创建。

---

## License

MIT
