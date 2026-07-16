# todolist 项目代码审查报告

**审查日期：** 2026-04-26
**审查范围：** 模型 (models), 控制器 (controllers), QML 界面 (qml), 服务器 (server), 入口 (main.py)
**审查工具：** OpenCode + superpowers/requesting-code-review Skill

---

## 一、审查范围

| 模块 | 文件数 | 说明 |
|------|--------|------|
| `models/` | 1 | 数据模型与数据库操作 (`task_model_optimized.py`) |
| `controllers/` | 1 | 业务逻辑控制器 (`task_controller_optimized.py`) |
| `server/` | 1 | FastAPI/HTTP 服务 (`app.py`) |
| `qml/` | 6 | 桌面端 UI 组件 (Material Design 3 风格) |
| `main.py` | 1 | 应用入口，包含内置 HTTP 服务器 |

---

## 二、发现的问题

### 🔴 Critical (P0)

**P0-1: 内置 HTTP 服务器 `do_POST` 缺乏 `try-except` 保护**
- **位置**: `main.py:340`
- **问题**: 解析 JSON 或处理数据时若发生异常（如 `json.JSONDecodeError`, `KeyError`），内置服务器线程会崩溃，导致后续所有请求断开。
- **建议**: 添加 `try-except json.JSONDecodeError` 块捕获解析错误并返回 400 状态码。

**P0-2: `task_model_optimized.py` 中多处缺少错误回滚**
- **位置**: `task_model_optimized.py` 多处 (如 `addTask`)
- **问题**: 数据库事务中若后续操作失败，前面已提交的数据可能导致状态不一致。
- **建议**: 在关键写入操作中使用事务回滚机制，确保原子性。

**P0-3: `moveTaskToQuadrant` 缺乏并发安全保护**
- **位置**: `task_model_optimized.py:453`
- **问题**: 读取旧象限值后、写入新值前，若有其他线程修改了该任务，会导致状态覆盖或事件发送错误。
- **建议**: 使用数据库事务包裹 `SELECT` 和 `UPDATE` 操作，或添加行级锁。

**P0-4: `setTaskCompleted` 中未完成的刷新逻辑**
- **位置**: `task_model_optimized.py:517`
- **问题**: 在调用 `refreshTasks()`（内部已有 `beginResetModel`）后，又额外发送了 `taskAdded.emit()`，且没有正确更新列表索引，可能导致 UI 渲染错乱或闪退。
- **建议**: 移除多余的 `taskAdded.emit()`，依赖 `refreshTasks()` 的全量刷新即可。

### 🟡 Important (P1)

**P1-1: `do_POST` 路由解析缺乏边界检查**
- **位置**: `main.py:350`
- **问题**: `parsed.path.split('/')[3]` 在路径层级不足时会抛出 `IndexError` 导致崩溃。
- **建议**: 检查 `len(parts)` 后再访问索引。

**P1-2: `Content-Length` 无限制**
- **位置**: `main.py:242`
- **问题**: 未限制 POST 请求体大小，可能导致 OOM 攻击。
- **建议**: 添加 `if length > 1MB: return 413` 检查。

**P1-3: 编辑对话框的两次写入**
- **问题**: 编辑任务时分别调用了更新属性和移动象限两个方法，导致两次数据库写入。
- **建议**: 合并为一个原子操作。

### 🟢 Minor (P2)

**P2-1: `AddTaskDialog.qml` 死代码**
- **位置**: `AddTaskDialog.qml` 第 345-399 行
- **问题**: `quadrantButtonComponent` 和 `createQuadrantButton` 定义了但从未使用。
- **建议**: 删除冗余代码。

**P2-2: 日志方式不统一**
- **问题**: 混用了 `print()` 和标准日志库。
- **建议**: 统一使用 `logger.info`。

---

## 三、总体评价

### 优势
- **MVC 架构清晰**：Model / Controller / View 分离合理，职责明确。
- **双引擎设计**：PySide6 桌面端 + FastAPI Web 端共用同一数据库，设计优雅。
- **API 设计标准**：RESTful 端点命名规范、HTTP 状态码使用正确。
- **文档完善**：`API.md` 详细描述了所有端点、请求/响应格式。
- **QML 设计现代化**：Material Design 3 配色、组件化程度高。

### 结论
**可上线：需要修复**。核心架构良好，但内置 HTTP 服务器的异常处理和并发安全需要优先处理。修复 4 个 Critical 问题后可安全使用。
