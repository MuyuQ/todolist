# 四象限Todo工具

## 项目介绍
这是一个基于Python和Qt Quick开发的四象限任务管理工具，采用MVC架构设计。

## 功能特点
- **四象限任务管理**：
  - 第一象限：重要且紧急
  - 第二象限：重要不紧急
  - 第三象限：不重要但紧急
  - 第四象限：不重要不紧急
- **任务操作**：
  - 添加/编辑任务
  - 标记任务完成状态
  - 移动任务到不同象限
- **现代化UI**：
  - 使用Qt Quick Controls 2的Material样式
  - 自定义控件样式和动画效果
  - 响应式布局

## 技术架构
- **前端**：Qt Quick/QML
- **后端**：Python/PySide6
- **数据存储**：SQLite数据库

## 文件结构
```
├── main.py                # 程序入口
├── controllers/           # 控制器模块
│   └── task_controller.py # 任务控制器
├── data/                  # 数据存储
│   └── tasks.db           # SQLite数据库
├── models/                # 模型模块
│   └── task_model.py      # 任务模型
└── qml/                   # QML界面文件
    ├── main.qml           # 主界面
    ├── QuadrantPanel.qml  # 四象限面板
    ├── TaskItem.qml       # 任务项组件
    └── ...                # 其他界面组件
```

## 运行方法
1. 安装依赖：
   ```
   pip install PySide6
   ```
2. 运行程序：
   ```
   python main.py
   ```

## 开发指南
1. **模型层**：`task_model.py`处理数据存储和业务逻辑
2. **控制器层**：`task_controller.py`处理用户交互逻辑
3. **视图层**：QML文件定义用户界面

## 注意事项
- 使用非原生样式以支持控件自定义
- 数据库文件存储在`data/tasks.db`
- 项目使用MIT许可证