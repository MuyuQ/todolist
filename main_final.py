import sys
import os
import locale
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, QUrl, QCoreApplication, Qt
from PySide6.QtQuickControls2 import QQuickStyle

# 创建一个日志处理类，用于处理QML中的console.log输出
class ConsoleLogger(QObject):
    @Slot(str)
    def log(self, message):
        print(str(message))

# 导入精简后的模型和控制器
from models.task_model_final import TaskModel
from controllers.task_controller_final import TaskController

def main():
    # 设置系统编码为UTF-8
    locale.setlocale(locale.LC_ALL, '')
    
    # 设置控制台编码为UTF-8（仅Windows平台）
    if sys.platform == 'win32':
        try:
            import ctypes
            ctypes.windll.kernel32.SetConsoleOutputCP(65001)
            ctypes.windll.kernel32.SetConsoleCP(65001)
        except Exception:
            pass
    
    # 确保Qt应用程序支持高DPI缩放
    QApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.PassThrough)
    QCoreApplication.setAttribute(Qt.ApplicationAttribute.AA_UseHighDpiPixmaps)
    QCoreApplication.setOrganizationName("TodoApp")
    QCoreApplication.setApplicationName("四象限Todo工具")
    
    app = QApplication(sys.argv)
    
    # 设置Qt Quick Controls 2样式为Material
    QQuickStyle.setStyle("Material")
    
    # 创建引擎
    engine = QQmlApplicationEngine()
    
    # 创建模型和控制器
    task_model = TaskModel()
    task_controller = TaskController(task_model)
    console_logger = ConsoleLogger()
    
    # 注册到QML上下文
    engine.rootContext().setContextProperty("taskModel", task_model)
    engine.rootContext().setContextProperty("taskController", task_controller)
    engine.rootContext().setContextProperty("consoleLogger", console_logger)
    
    # 加载主QML文件
    qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))
    
    if not engine.rootObjects():
        return -1
    
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())