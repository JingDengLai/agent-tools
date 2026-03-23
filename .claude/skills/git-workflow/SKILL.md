---
name: git-workflow
description: 当需要完成开发任务，并且必须执行完整 Git 工作流（创建分支、提交代码、推送、生成 PR）时使用
---

# Git 工作流 Skill

此 Skill 确保每个开发任务严格按照标准 Git 流程执行，包括：

- 自动生成分支
- 提交代码
- 推送远程
- 创建 Pull Request
- 自动检查环境是否支持 PR

---

## 使用场景

- 新功能开发
- Bug 修复
- 代码重构

> 注意：如果用户环境不满足创建 PR 条件（未安装 gh CLI 或未登录等），Skill 会提示用户去配置。

---

## 执行步骤

1. 判断任务类型（feature / fix / refactor）  
2. 生成分支名称 `<type>/<short-name>`  
3. 生成 commit message `<type>: <简要描述>`  
4. 调用 scripts/auto-git.sh 执行 Git 操作并创建 PR  
5. 输出分支、commit、PR 内容  

---

## 调用方式

```bash
bash scripts/auto-git.sh "<task_description>"