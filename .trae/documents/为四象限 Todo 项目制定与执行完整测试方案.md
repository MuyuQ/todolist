## 测试目标
- 验证数据层、控制器、桌面 QML UI、内置 WebAPI 与 WebUI 的正确性与一致性
- 覆盖新增、更新、移动、完成、删除、清空操作及列表刷新、主题一致性与性能边界
- 在 Windows 环境下提供可复现的执行步骤与通过/失败判定标准

## 范围与对象
- 数据层：`models/task_model_optimized.py`（添加、更新、移动、完成、排序、删除、查询、清空）
- 控制器：`controllers/task_controller_optimized.py`（各操作发出 `taskUpdated` 信号与结果一致性）
- 桌面 UI：`qml/main.qml`（Tab 切换、清空按钮与 `refreshCompletedTasksList()` 刷新逻辑）
- WebAPI：`main.py` 内置 `AppHTTPRequestHandler` 提供的 REST 端点
- WebUI：`webui/index.html`（统一主题、交互完整性）

## 现有测试资产盘点
- 启动与 Web 端口验证：`test_clear_button.py`
- 数据与功能验证：`test_clear_functionality.py`、`test_clear_ui.py`、`precise_clear_test.py`、`final_clear_verification.py`
- 删除功能验证：`test_delete_buttons.py`
- 辅助：`setup_test_data.py`、`check_db.py`

## 测试分类与用例
### 1. 数据层单元测试
- `addTask()` 验证空标题拒绝与插入成功（models/task_model_optimized.py:158–191）
- `setTaskCompleted()` 完成/未完成状态切换与模型变更（193–224）
- `updateTask()` 标题/描述更新与角色刷新（225–245）
- `moveTaskToQuadrant()` 象限合法性与变更信号（246–278）
- `updateTaskOrder()` 排序索引更新与查询顺序影响（337–358）
- `deleteTask()` 从数据库与模型同步删除（382–399）
- `clearCompletedTasks()` 清空完成任务（401–410）
- 查询：`getAllTasks()`、`getTasksByQuadrant()`、`getCompletedTasks()` 字段映射与数量（359–380, 279–307, 309–331）
- 数据库结构与迁移：`init_database()` 确保 `order_index` 存在（64–96）

### 2. 控制器单元与契约测试
- 方法映射与信号：`TaskController` 在各操作后发出 `taskUpdated`（controllers/task_controller_optimized.py:3–86）
- `getCompletedTasks()` 与模型返回字段一致性（66–69）
- 刷新流程：`refreshTasks()` 更新后列表变化（44–48）

### 3. 桌面 QML UI 功能测试
- Tab 切换：`completedTasksTab` 切换到完成任务页后延迟刷新（qml/main.qml:101–148）
- 清空按钮：点击触发 `taskController.clearCompletedTasks()` 并调用刷新（329–337）
- 刷新函数：`refreshCompletedTasksList()` 在完成页强制刷新 ListView 的 `model`（430–484）
- 视觉一致性：主题色与滚动条样式（15–26, 370–387）
- 测试方法：使用 PySide6 的 `QTest` 或现有脚本模拟，断言完成数量变化与 UI 日志输出

### 4. WebAPI 集成测试（无依赖回退）
- 端点：
  - `GET /api/tasks`、`GET /api/tasks/completed`
  - `POST /api/tasks`
  - `PATCH /api/tasks/{id}`、`/quadrant`、`/complete`
  - `DELETE /api/tasks/{id}`、`/api/tasks/completed`
- 验证：状态码、响应体字段、数据库副作用（`data/tasks.db`）
- 服务器：`AppHTTPRequestHandler`（main.py:27 定义，路由在类内各 `do_*` 实现）

### 5. WebUI 端到端测试
- 页面加载与主题：颜色变量与布局与 QML 对齐（`webui/index.html`）
- 交互：添加任务、象限移动、标记完成、切换到“已完成任务”、清空功能
- 断言：列表数量变化、文案与样式类名存在、按钮行为正确
- 工具：Playwright 或 Selenium（在本地环境允许时执行）

### 6. 一致性与回归
- 通过 WebAPI 修改数据后，桌面 QML 启动显示一致（同库共享）
- 通过桌面端操作后，WebUI 刷新读取一致
- 边界：大量任务（如 1000 条）下查询排序与 UI 性能

### 7. 异常与安全
- 非法象限（<1 或 >4）拒绝与无副作用（数据层 248–251 的保护）
- 空标题插入拒绝（160–161）
- SQL 注入与输入转义（使用参数化查询）
- API 错误返回结构化 JSON（内置服务器返回 `{"error": ...}`）

## 测试数据与隔离
- 使用 `setup_test_data.py` 初始化数据集与完成状态
- 测试前后快照：复制 `data/tasks.db` 到临时文件夹，运行测试指向副本，测试结束回滚
- 备选：在模型层引入可配置 `db_path`（当前为固定路径），测试通过 monkeypatch 或环境变量注入（需要迭代时实现）

## 执行步骤（建议顺序）
1. 启动 Web 模式：`python main.py --mode web`（验证端口 8080 可访问）
2. 运行现有脚本：
   - `python test_clear_button.py`（启动与端口检测）
   - `python test_clear_functionality.py`（添加数据，清空功能，数据库检查）
   - `python test_clear_ui.py`（控制器与数据库一致性）
   - `python precise_clear_test.py`（UI 刷新路径验证）
   - `python final_clear_verification.py`（完整清空流程）
   - `python test_delete_buttons.py`（删除按钮流程）
3. WebAPI 用例（可使用 `requests`）：逐端点对新增/更新/移动/完成/删除/清空进行断言
4. WebUI 交互测试：打开 `http://localhost:8080/`，执行交互并观察列表变化
5. 视觉一致性检查：配色、滚动条、布局与 QML 比对

## 判定标准
- 数据层：各方法行为与返回值正确，数据库记录与模型内存一致
- 控制器：每个操作后均发出 `taskUpdated`，UI 侧能刷新
- 桌面 UI：清空后 `CompletedTaskItem` 列表为空且日志显示刷新完成
- WebAPI：所有端点状态码与返回字段符合预期，副作用准确
- WebUI：操作后列表数量正确，样式与交互无异常

## 报告与问题追踪
- 汇总每项测试的通过/失败与日志要点
- 对失败项记录实际与预期差异、涉及代码位置（例如：`models/task_model_optimized.py:401–410`）与复现步骤

## 后续扩展
- 引入 `pytest` 把脚本整合为统一测试套件与夹具（fixture）
- 若网络允许，改用 FastAPI 的 `TestClient`，在 `server/app.py` 层进行更细致的 API 测试
- 前端升级至 Playwright 提供跨浏览器自动化与快照对比
