
---

## 3️⃣ `examples.md`

```md id="ex1"
# Git Workflow Examples

### 示例 1

输入：
新增订单部分退款功能

输出：
- 分支：feature/partial-refund
- commit：feat: add partial refund support
- PR 内容：
  - Title：Add partial refund support
  - Description：
    - 支持订单部分退款
    - 更新订单金额计算逻辑
    - 测试方式：创建订单 → 执行部分退款 → 校验金额变化

---

### 示例 2

输入：
修复支付状态错误问题

输出：
- 分支：fix/payment-status-bug
- commit：fix: correct payment status logic
- PR 内容：
  - Title：Fix payment status bug
  - Description：
    - 修复支付状态判断错误
    - 测试方式：模拟支付失败 → 验证状态更新