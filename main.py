import sys
import os
import locale
import io
import ctypes
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, QJSValue
from PySide6.QtCore import QObject, Signal, Property, Slot, QUrl, QCoreApplication, Qt, QTranslator
from PySide6.QtQuickControls2 import QQuickStyle

# 在Windows平台上设置控制台编码为UTF-8
if sys.platform == 'win32':
    # 尝试设置Windows控制台代码页为UTF-8 (65001)
    try:
        # 设置控制台输出代码页为UTF-8
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
        # 设置控制台输入代码页为UTF-8
        ctypes.windll.kernel32.SetConsoleCP(65001)
    except Exception as e:
        print(f"设置Windows控制台编码失败: {str(e)}")

# 设置标准输出编码为UTF-8
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# 创建一个日志处理类，用于处理QML中的console.log输出
class ConsoleLogger(QObject):
    @Slot(str)
    def log(self, message):
        # 确保中文字符正确显示，根据不同平台处理编码
        try:
            # 在Windows环境下特别处理控制台输出
            if sys.platform == 'win32':
                # 确保消息是字符串类型
                if not isinstance(message, str):
                    message = str(message)
                # 直接输出，依赖前面设置的控制台代码页和stdout编码
                print(message)
            else:
                # 非Windows平台直接输出
                print(message)
        except Exception as e:
            print(f"日志输出错误: {str(e)}")
            # 尝试使用不同方式输出原始消息，帮助调试
            try:
                print(f"原始消息类型: {type(message)}")
                print(f"原始消息内容: {repr(message)}")
            except:
                pass


from models.task_model import TaskModel
from controllers.task_controller import TaskController

if __name__ == "__main__":
    # 设置系统编码为UTF-8
    locale.setlocale(locale.LC_ALL, '')
    # 确保Qt应用程序使用UTF-8编码
    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    QCoreApplication.setOrganizationName("TodoApp")
    QCoreApplication.setApplicationName("四象限Todo工具")
    
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