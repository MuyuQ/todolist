import sys  # 系统模块，用于访问与Python解释器和系统相关的变量和函数
import os  # 操作系统接口模块，提供与操作系统交互的功能
import locale  # 本地化模块，用于处理区域设置
from PySide6.QtWidgets import QApplication  # 提供Qt应用程序基础类
from PySide6.QtQml import QQmlApplicationEngine  # QML引擎，用于加载和运行QML文件
from PySide6.QtCore import QObject, Slot, QUrl, QCoreApplication, Qt  # Qt核心功能
from PySide6.QtQuickControls2 import QQuickStyle  # 控制Qt Quick样式

# 设置控制台编码为UTF-8（仅Windows平台）
# 这确保了在Windows控制台中正确显示中文和其他Unicode字符
if sys.platform == 'win32':
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)  # 设置控制台输出代码页为UTF-8
        ctypes.windll.kernel32.SetConsoleCP(65001)  # 设置控制台输入代码页为UTF-8
    except Exception:
        pass

# 创建一个日志处理类，用于处理QML中的console.log输出
# 这个类将被注册到QML上下文中，使QML代码可以通过它输出日志信息到Python控制台
class ConsoleLogger(QObject):
    @Slot(str)  # 将此方法标记为可从QML调用的槽函数，接受一个字符串参数
    def log(self, message):
        """将QML中的日志消息打印到Python控制台
        
        Args:
            message: 要打印的日志消息
        """
        print(str(message))


# 导入应用程序所需的模型和控制器类
from models.task_model import TaskModel  # 任务数据模型，负责数据管理和持久化
from controllers.task_controller import TaskController  # 任务控制器，处理业务逻辑

if __name__ == "__main__":
    # 设置系统编码为UTF-8，确保正确处理国际化字符
    locale.setlocale(locale.LC_ALL, '')
    
    # 配置Qt应用程序的高DPI支持
    # 注意：在PySide6中，高DPI缩放默认已启用，不再需要显式设置这些属性
    # 以下两行代码保留但已注释，因为它们已被标记为过时
    # QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling)  # 启用高DPI缩放，使UI在高分辨率显示器上正常显示
    # QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps)  # 使用高DPI图标，确保图标清晰
    
    # 设置应用程序信息
    QCoreApplication.setOrganizationName("TodoApp")  # 设置组织名称，用于存储设置等
    QCoreApplication.setApplicationName("四象限Todo工具")  # 设置应用程序名称
    
    # 创建Qt应用程序实例
    app = QApplication(sys.argv)  # 传入命令行参数
    
    # 设置Qt Quick Controls 2样式为Material
    # 使用非原生样式以支持控件自定义，提供现代化的Material Design外观
    QQuickStyle.setStyle("Material")
    
    # 创建QML引擎，用于加载和运行QML界面
    engine = QQmlApplicationEngine()
    
    # 创建应用程序的核心组件
    task_model = TaskModel()  # 创建任务数据模型实例
    task_controller = TaskController(task_model)  # 创建任务控制器实例，并关联数据模型
    
    # 创建日志处理器，用于QML中的日志输出
    console_logger = ConsoleLogger()
    
    # 将Python对象注册到QML上下文，使QML代码可以访问这些对象
    engine.rootContext().setContextProperty("taskModel", task_model)  # 注册任务模型
    engine.rootContext().setContextProperty("taskController", task_controller)  # 注册任务控制器
    engine.rootContext().setContextProperty("consoleLogger", console_logger)  # 注册日志处理器
    
    # 加载主QML文件，构建用户界面
    qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))
    
    # 检查QML是否成功加载，如果加载失败则退出应用程序
    if not engine.rootObjects():
        sys.exit(-1)  # 返回错误代码
    
    # 启动应用程序主事件循环，并在退出时返回应用程序的退出代码
    sys.exit(app.exec())