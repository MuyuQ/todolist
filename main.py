import sys
import os
import locale
import threading
import time
import json
import sqlite3
from urllib.parse import urlparse
from http.server import HTTPServer, SimpleHTTPRequestHandler, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, QUrl, QCoreApplication, Qt
from PySide6.QtQuickControls2 import QQuickStyle

# 创建一个日志处理类，用于处理QML中的console.log输出
class ConsoleLogger(QObject):
    @Slot(str)
    def log(self, message):
        print(str(message))

# 简单的Web服务器类
class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    pass

class AppHTTPRequestHandler(BaseHTTPRequestHandler):
    def _json(self, data, code=200):
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _db(self):
        db_path = os.path.join(os.path.dirname(__file__), 'data', 'tasks.db')
        conn = sqlite3.connect(db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _row(self, row):
        return {
            'id': row['id'],
            'title': row['title'] or '',
            'description': row['description'] or '',
            'quadrant': row['quadrant'],
            'isCompleted': bool(row['is_completed']),
            'createdAt': row['created_at'],
            'orderIndex': row['order_index'] if 'order_index' in row.keys() else 0
        }

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == '/':
            index_path = os.path.join(os.path.dirname(__file__), 'webui', 'index.html')
            if os.path.exists(index_path):
                with open(index_path, 'rb') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.send_header('Content-Length', str(len(content)))
                self.end_headers()
                self.wfile.write(content)
                return
        if parsed.path == '/api/tasks':
            conn = self._db()
            cur = conn.cursor()
            cur.execute('SELECT * FROM tasks WHERE is_completed = 0 ORDER BY quadrant ASC, order_index ASC, created_at DESC')
            rows = cur.fetchall()
            conn.close()
            self._json([self._row(r) for r in rows])
            return
        if parsed.path == '/api/tasks/completed':
            conn = self._db()
            cur = conn.cursor()
            cur.execute('SELECT * FROM tasks WHERE is_completed = 1 ORDER BY created_at DESC')
            rows = cur.fetchall()
            conn.close()
            self._json([self._row(r) for r in rows])
            return
        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path == '/api/tasks':
            length = int(self.headers.get('Content-Length', '0'))
            payload = json.loads(self.rfile.read(length) or b'{}')
            title = payload.get('title', '').strip()
            description = payload.get('description', '')
            quadrant = int(payload.get('quadrant', 4))
            if not title:
                self._json({'error': 'title required'}, 400)
                return
            conn = self._db()
            cur = conn.cursor()
            cur.execute('INSERT INTO tasks (title, description, quadrant) VALUES (?, ?, ?)', (title, description, quadrant))
            conn.commit()
            task_id = cur.lastrowid
            cur.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
            row = cur.fetchone()
            conn.close()
            self._json(self._row(row), 201)
            return
        self.send_response(404)
        self.end_headers()

    def do_PATCH(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get('Content-Length', '0'))
        payload = json.loads(self.rfile.read(length) or b'{}')
        if parsed.path.startswith('/api/tasks/') and parsed.path.endswith('/quadrant'):
            task_id = int(parsed.path.split('/')[3])
            quadrant = int(payload.get('quadrant', 4))
            conn = self._db()
            cur = conn.cursor()
            cur.execute('UPDATE tasks SET quadrant = ? WHERE id = ?', (quadrant, task_id))
            conn.commit()
            cur.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
            row = cur.fetchone()
            conn.close()
            if row is None:
                self._json({'error': 'not found'}, 404)
            else:
                self._json(self._row(row))
            return
        if parsed.path.startswith('/api/tasks/') and parsed.path.endswith('/complete'):
            task_id = int(parsed.path.split('/')[3])
            completed = bool(payload.get('completed', True))
            conn = self._db()
            cur = conn.cursor()
            cur.execute('UPDATE tasks SET is_completed = ? WHERE id = ?', (1 if completed else 0, task_id))
            conn.commit()
            cur.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
            row = cur.fetchone()
            conn.close()
            if row is None:
                self._json({'error': 'not found'}, 404)
            else:
                self._json(self._row(row))
            return
        if parsed.path.startswith('/api/tasks/') and not parsed.path.endswith('/complete') and not parsed.path.endswith('/quadrant'):
            task_id = int(parsed.path.split('/')[3])
            title = payload.get('title')
            description = payload.get('description')
            conn = self._db()
            cur = conn.cursor()
            cur.execute('UPDATE tasks SET title = COALESCE(?, title), description = COALESCE(?, description) WHERE id = ?', (title, description, task_id))
            conn.commit()
            cur.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
            row = cur.fetchone()
            conn.close()
            if row is None:
                self._json({'error': 'not found'}, 404)
            else:
                self._json(self._row(row))
            return
        self.send_response(404)
        self.end_headers()

    def do_DELETE(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith('/api/tasks/') and parsed.path.count('/') == 3:
            task_id = int(parsed.path.split('/')[3])
            conn = self._db()
            cur = conn.cursor()
            cur.execute('DELETE FROM tasks WHERE id = ?', (task_id,))
            conn.commit()
            conn.close()
            self._json({'ok': True})
            return
        if parsed.path == '/api/tasks/completed':
            conn = self._db()
            cur = conn.cursor()
            cur.execute('DELETE FROM tasks WHERE is_completed = 1')
            conn.commit()
            conn.close()
            self._json({'ok': True})
            return
        self.send_response(404)
        self.end_headers()

# 导入应用程序所需的模型和控制器类
from models.task_model_optimized import TaskModel
from controllers.task_controller_optimized import TaskController

def start_web_server():
    try:
        port = 8080
        server = ThreadedHTTPServer(('localhost', port), AppHTTPRequestHandler)
        print(f"Web服务器已启动，访问 http://localhost:{port}")
        server.serve_forever()
    except Exception as e:
        print(f"Web服务器启动失败: {str(e)}")

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
        
        # 启动Web服务器
        web_server_thread = threading.Thread(target=start_web_server, daemon=True)
        web_server_thread.start()
        
        # 等待一下确保Web服务器启动
        time.sleep(1)
        
        # 启动事件循环
        return app.exec()
    
    except Exception as e:
        print(f"应用程序发生未预期的错误: {str(e)}")
        import traceback
        traceback.print_exc()
        return -6

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["desktop", "web"], default="desktop")
    args = parser.parse_args()
    if args.mode == "web":
        try:
            import uvicorn
            from server.app import app
            uvicorn.run(app, host="127.0.0.1", port=8080)
        except Exception:
            start_web_server()
    else:
        sys.exit(main())