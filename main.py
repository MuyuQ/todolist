import sys
import os
import locale
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, QUrl, QCoreApplication, Qt
from PySide6.QtQuickControls2 import QQuickStyle

# 设置控制台编码为UTF-8（仅Windows平台）
if sys.platform == 'win32':
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
        ctypes.windll.kernel32.SetConsoleCP(65001)
    except Exception:
        pass

# 创建一个日志处理类，用于处理QML中的console.log输出
class ConsoleLogger(QObject):
    @Slot(str)
    def log(self, message):
        print(str(message))


from models.task_model import TaskModel
from controllers.task_controller import TaskController

if __name__ == "__main__":
    # 设置系统编码为UTF-8
    locale.setlocale(locale.LC_ALL, '')
    # 确保Qt应用程序支持高DPI缩放
    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling) # 对于Qt 5.6+
    QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps) # 使用高DPI图标
    QCoreApplication.setOrganizationName("TodoApp")
    QCoreApplication.setApplicationName("四象限Todo工具")
    
    app = QApplication(sys.argv)
    
    # 设置Qt Quick Controls 2样式为Material
    # 使用非原生样式以支持控件自定义
    QQuickStyle.setStyle("Material")
    
    # 创建引擎
    engine = QQmlApplicationEngine()
    
    # 创建模型和控制器
    task_model = TaskModel()
    task_controller = TaskController(task_model)
    
    # 创建日志处理器
    console_logger = ConsoleLogger()
    
    # 注册到QML上下文
    engine.rootContext().setContextProperty("taskModel", task_model)
    engine.rootContext().setContextProperty("taskController", task_controller)
    engine.rootContext().setContextProperty("consoleLogger", console_logger)
    
    # 加载主QML文件
    qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())