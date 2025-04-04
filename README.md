# 待办事项应用

基于Qt Quick/QML实现的现代化待办事项管理应用，采用四象限法则进行任务分类。

## 功能特点

- **四象限任务管理**：根据重要性和紧急性将任务分为四个象限
- **美观的UI设计**：采用Material Design风格，包含自定义动画和过渡效果
- **完整CRUD功能**：支持任务的创建、读取、更新和删除
- **响应式布局**：适配不同屏幕尺寸的设备
- **本地数据存储**：使用SQLite数据库持久化存储任务数据
- **自定义样式系统**：通过CommonStyles.qml统一管理应用样式

## 技术栈

- **前端**：Qt Quick/QML 2.15
- **后端**：Python 3
- **数据库**：SQLite
- **UI框架**：Qt Quick Controls 2 Material风格

## 项目结构

```
├── controllers/       # 控制器逻辑
│   ├── task_controller.py       # 任务控制器
│   └── ...
├── data/              # 数据存储
│   └── tasks.db      # SQLite数据库文件
├── fonts/             # 字体资源
├── models/            # 数据模型
│   ├── task_model.py  # 任务数据模型
│   ├── db_manager.py  # 数据库管理
│   └── ...
├── qml/               # QML界面组件
│   ├── CommonStyles.qml  # 全局样式定义
│   ├── Utils.qml         # 工具函数(日期格式化等)
│   ├── imports.qml      # 统一导入声明
│   ├── QuadrantPanel.qml # 四象限面板
│   ├── TaskItem.qml     # 任务项组件
│   └── ...
├── main.py            # 应用入口
└── README.md          # 项目文档
```

## 安装与运行

### 前提条件
- Python 3.8+
- Qt 5.15
- PySide2

### 步骤
1. 克隆仓库：`git clone <repo-url>`
2. 安装依赖：`pip install PySide2`
3. 运行应用：`python main.py`

## 开发指南

### 样式定制
所有样式定义在`qml/CommonStyles.qml`中，包括：
- 对话框样式
- 输入框样式
- 列表项样式
- 颜色系统
- 间距系统

### 工具函数
`qml/Utils.qml`提供了常用工具函数：
- 象限颜色和标题获取
- 日期时间格式化
- 文本截断

## 贡献指南

欢迎通过Pull Request贡献代码，请确保：
1. 代码风格与现有代码一致
2. 添加适当的注释
3. 更新相关文档

## 许可证

MIT License