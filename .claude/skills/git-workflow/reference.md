# Git Workflow Skill Reference

## 输出格式（必遵守）

### 1️⃣ 分支
- 字段名：`branch`
- 类型：字符串
- 示例：feature/partial-refund


---

### 2️⃣ Git 命令
- 字段名：`git_commands`
- 类型：bash 命令块
- 内容：
```bash
git checkout -b <branch-name>
git add .
git commit -m "<commit-message>"
git push origin <branch-name>
```
- 示例：
```bash
git checkout -b feature/partial-refund
git add .
git commit -m "feat: add partial refund support"
git push origin feature/partial-refund
```

### 3️⃣ Pull Request
- 字段名：pull_request
- 类型：对象
- 内容：
  - title：PR 标题，一句话描述修改内容
  - description：详细说明修改内容、涉及文件及测试步骤
- 示例：
  - Title: Add partial refund support
  - Description:
    - 功能说明：新增订单部分退款功能
    - 修改内容：更新订单金额计算逻辑
    - 测试方式：创建订单 → 执行部分退款 → 校验金额变化
