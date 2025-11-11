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

# 导入应用程序所需的模型和控制器类
from models.task_model_optimized import TaskModel
from controllers.task_controller_optimized import TaskController

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
            print("警告: 无法设置控制台编码为UTF-8")
    
    try:
        # 配置Qt应用程序的高DPI支持
        QApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.PassThrough)
        
        # 设置应用程序信息
        QCoreApplication.setOrganizationName("TodoApp")
        QCoreApplication.setApplicationName("四象限Todo工具")
        
        # 创建应用程序实例
        app = QApplication(sys.argv)
        
        # 设置样式
        QQuickStyle.setStyle("Material")
        
        # 创建QML引擎
        engine = QQmlApplicationEngine()
        
        # 创建核心组件
        try:
            task_model = TaskModel()
            task_controller = TaskController(task_model)
            console_logger = ConsoleLogger()
        except Exception as e:
            print(f"错误: 创建核心组件失败: {str(e)}")
            return -2
        
        # 注册到QML上下文
        engine.rootContext().setContextProperty("taskModel", task_model)
        engine.rootContext().setContextProperty("taskController", task_controller)
        engine.rootContext().setContextProperty("consoleLogger", console_logger)
        
        # 加载主QML文件
        qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
        
        if not os.path.exists(qml_file):
            print(f"错误: 找不到主QML文件: {qml_file}")
            return -3
        
        try:
            engine.load(QUrl.fromLocalFile(qml_file))
        except Exception as e:
            print(f"错误: 加载QML文件失败: {str(e)}")
            return -4
        
        # 检查加载是否成功
        if not engine.rootObjects():
            print("错误: 无法创建应用程序根对象")
            return -5
        
        # 连接QML错误信号
        engine.warnings.connect(lambda warnings: [print(f"QML警告: {w.toString()}") for w in warnings])
        
        # 启动事件循环
        return app.exec()
    
    except Exception as e:
        print(f"应用程序发生未预期的错误: {str(e)}")
        import traceback
        traceback.print_exc()
        return -6

if __name__ == "__main__":
    sys.exit(main())  # 执行主函数并将返回值传递给sys.exit()