## 当前架构概览
- 桌面端：Python + PySide6 + QML，SQLite 数据库（`models/task_model_optimized.py` 使用 `data/tasks.db`）
- 入口与样式：`main.py` 加载 `qml/main.qml`，使用 `QQuickStyle.setStyle("Material")` 与自定义调色板（`qml/main.qml:15–26`）
- Web服务器占位：`main.py:57–66, 132–138` 内置 `SimpleHTTPServer` 仅返回占位 HTML，尚未真正接入业务与 UI

## 目标与原则
- 保持现有桌面端不变，同时提供 WebUI 启动方式
- 统一视觉风格（Material 主题与项目自定义色），减少重复逻辑
- 复用现有数据层与业务能力，API 化控制器，保证性能与可维护性

## 技术栈选项
- 方案 A（推荐）：Python 后端 FastAPI + 前端 React(Vite) + MUI
  - 优点：成熟生态、强类型 API（Pydantic）、前端组件丰富，易实现与 QML 接近的 Material 风格
  - 风险与成本：新增 Node 前端与依赖；但与现有 Python 很好分层
- 方案 B（纯 Python Web）：FastAPI + Jinja2 + HTMX 或 NiceGUI（Quasar/Material）
  - 优点：不引入 Node；上手快
  - 取舍：复杂交互与动画的精细度较方案 A 弱，视觉一致性可达“接近”而非“完全”
- 方案 C（重构为 Tauri + React/Vite）
  - 优点：统一桌面与 Web 的前端栈、体积小于 Electron
  - 取舍：迁移代价较高，需要替换 Python/PySide6；不建议当前阶段

## 推荐实施路径（方案 A）
### 后端 API 设计
- 引入 FastAPI，复用数据层，封装 `TaskController` 功能为 REST API：
  - `GET /api/tasks`、`GET /api/tasks/completed`
  - `POST /api/tasks`（新增）
  - `PATCH /api/tasks/{id}`（更新标题/描述）
  - `PATCH /api/tasks/{id}/complete`、`PATCH /api/tasks/{id}/quadrant`
  - `DELETE /api/tasks/{id}`、`DELETE /api/tasks/completed`
- 数据模型：Pydantic 校验，请求/响应统一字段命名，映射现有 QML 数据结构（如 `getCompletedTasks` 的字段）
- 复用数据库：`data/tasks.db`，保留当前 schema 与事务封装（`TaskModel._execute_query`）

### WebUI 风格与页面
- 前端：Vite + React + MUI（Material），建立统一主题：
  - 调色板映射 `qml/main.qml`：`primary("#4361ee")/secondary("#3f37c9")/accent("#4cc9f0")/...`
  - 组件层级与交互参考 QML：顶部导航、Tab 切换、四象限网格、添加/编辑对话框、已完成任务清单与“清空”按钮
  - 动效：入场/出场过渡与滚动条样式对齐（与 QML 的 Transition/ScrollBar 配置）

### 启动方式与运行模式
- 桌面模式：保持 `python main.py` 原行为，加载 QML
- Web 模式：
  - 增加 CLI 参数：`python main.py --mode web` 或 `--web`
  - 启动 `uvicorn` 提供 API 与静态文件服务（`webui/dist`）
  - 开发期：前端 `npm run dev`（Vite）在 `5173` 端口，后端在 `8080`，启用 CORS；生产期：后端挂载打包好的静态资源并统一端口
  - 自动打开浏览器到相应地址

### 目录与依赖（新增）
- 后端：`server/app.py`（或集成到 `main.py` 的 `webui_server` 模块），`requirements.txt` 增加 `fastapi`, `uvicorn`, `pydantic`
- 前端：`webui/`（Vite + React + MUI），产出 `webui/dist`
- 保持现有 Python 依赖（PySide6），不影响桌面模式

### 性能与安全
- 连接管理：沿用短连接 + 事务提交；后续可引入连接池与只读查询优化
- CORS：开发期仅允许本机端口；生产期关闭 CORS
- 输入校验与错误处理：统一返回码与错误体；日志不泄漏敏感数据

### 验证与测试
- API 单元测试：`pytest` + FastAPI TestClient
- 前端集成测试：关键流程（新增/完成/删除/清空）
- 视觉一致性核对：颜色、间距、动效与滚动条样式
- 回归测试：桌面端功能不回归（现有 QML 交互照常运行）

## 实施阶段
- 阶段 1：抽象服务层，封装 `TaskController` 到 API；搭建 FastAPI
- 阶段 2：搭建前端项目，实现四象限与列表页面，接入 API
- 阶段 3：新增 Web 模式启动参数与浏览器自动打开；打包静态资源到后端
- 阶段 4：主题统一与动效细化；测试与文档

## 可选最小化路径（方案 B）
- 不引入 Node：使用 FastAPI + Jinja2 + HTMX 或 NiceGUI 实现 WebUI
- 保证基础交互与风格接近 Material；如需完全一致的组件细节，建议仍选方案 A

## 交付物
- 后端：API 服务与启动参数、`requirements.txt`
- 前端：`webui/` 源码与打包产物、统一主题配置
- 使用说明：桌面模式与 Web 模式的启动方式