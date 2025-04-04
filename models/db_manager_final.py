import sqlite3
import os
from contextlib import contextmanager

class DatabaseManager:
    """数据库管理器类，集中处理所有数据库操作"""
    
    def __init__(self, db_path=None):
        # 如果未提供数据库路径，使用默认路径
        if db_path is None:
            # 获取当前文件所在目录的上级目录，然后添加data/tasks.db
            self.db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "tasks.db")
        else:
            self.db_path = db_path
        
        # 确保数据目录存在
        self._ensure_data_dir()
        # 初始化数据库结构
        self._init_database()
    
    def _ensure_data_dir(self):
        """确保数据目录存在"""
        data_dir = os.path.dirname(self.db_path)
        if not os.path.exists(data_dir):
            os.makedirs(data_dir)
    
    @contextmanager
    def get_connection(self):
        """获取数据库连接，使用上下文管理器模式自动关闭连接"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row  # 使结果可以通过列名访问
        try:
            yield conn
        finally:
            conn.close()
    
    def execute_query(self, query, params=(), fetch_all=False, commit=False):
        """执行SQL查询并返回结果
        
        Args:
            query: SQL查询语句
            params: 查询参数
            fetch_all: 是否获取所有结果
            commit: 是否提交事务
            
        Returns:
            如果fetch_all为True，返回所有结果行
            如果fetch_all为False，返回单个结果行
            如果commit为True，返回lastrowid或True
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            
            if commit:
                conn.commit()
                return cursor.lastrowid if cursor.lastrowid else True
            
            if fetch_all:
                return cursor.fetchall()
            else:
                return cursor.fetchone()
    
    def _init_database(self):
        """初始化数据库结构"""
        with self.get_connection() as conn:
            cursor = conn.cursor()
            
            # 创建任务表
            cursor.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                quadrant INTEGER DEFAULT 4,
                is_completed BOOLEAN DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                order_index INTEGER DEFAULT 0
            )
            ''')
            
            # 检查是否需要添加order_index列
            cursor.execute("PRAGMA table_info(tasks)")
            columns = cursor.fetchall()
            has_order_index = any(column[1] == 'order_index' for column in columns)
            
            if not has_order_index:
                cursor.execute("ALTER TABLE tasks ADD COLUMN order_index INTEGER DEFAULT 0")
            
            conn.commit()
    
    # 任务相关操作
    def get_all_tasks(self, completed=False):
        """获取所有任务"""
        return self.execute_query(
            "SELECT * FROM tasks WHERE is_completed = ? ORDER BY created_at DESC",
            (1 if completed else 0,),
            fetch_all=True
        )
    
    def get_tasks_by_quadrant(self, quadrant):
        """获取指定象限的任务"""
        return self.execute_query(
            "SELECT * FROM tasks WHERE quadrant = ? AND is_completed = 0 ORDER BY order_index ASC, created_at DESC",
            (quadrant,),
            fetch_all=True
        )
    
    def add_task(self, title, description, quadrant=4):
        """添加新任务"""
        return self.execute_query(
            "INSERT INTO tasks (title, description, quadrant) VALUES (?, ?, ?)",
            (title, description, quadrant),
            commit=True
        )
    
    def update_task(self, task_id, title, description):
        """更新任务信息"""
        return self.execute_query(
            "UPDATE tasks SET title = ?, description = ? WHERE id = ?",
            (title, description, task_id),
            commit=True
        )
    
    def set_task_completed(self, task_id, completed=True):
        """设置任务完成状态"""
        return self.execute_query(
            "UPDATE tasks SET is_completed = ? WHERE id = ?",
            (1 if completed else 0, task_id),
            commit=True
        )
    
    def move_task_to_quadrant(self, task_id, new_quadrant):
        """移动任务到新象限"""
        # 获取旧象限
        old_quadrant_row = self.execute_query(
            "SELECT quadrant FROM tasks WHERE id = ?", 
            (task_id,)
        )
        
        if not old_quadrant_row:
            return False, None
        
        old_quadrant = old_quadrant_row['quadrant']
        
        # 更新象限
        success = self.execute_query(
            "UPDATE tasks SET quadrant = ? WHERE id = ?",
            (new_quadrant, task_id),
            commit=True
        )
        
        return success, old_quadrant
    
    def update_task_order(self, task_id, new_order_index):
        """更新任务排序"""
        return self.execute_query(
            "UPDATE tasks SET order_index = ? WHERE id = ?",
            (new_order_index, task_id),
            commit=True
        )