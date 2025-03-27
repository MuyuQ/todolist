import sys
import os
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Property, Slot, QUrl
from PySide6.QtQuickControls2 import QQuickStyle

from models.task_model import TaskModel
from controllers.task_controller import TaskController

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setApplicationName("四象限Todo工具")
    
    # 设置Qt Quick Controls 2样式为Material
    # 使用非原生样式以支持控件自定义
    QQuickStyle.setStyle("Material")
    
    # 创建引擎
    engine = QQmlApplicationEngine()
    
    # 创建模型和控制器
    task_model = TaskModel()
    task_controller = TaskController(task_model)
    
    # 注册到QML上下文
    engine.rootContext().setContextProperty("taskModel", task_model)
    engine.rootContext().setContextProperty("taskController", task_controller)
    
    # 加载主QML文件
    qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())