from PySide6.QtCore import QObject, Signal, Property, Slot, QAbstractListModel, QModelIndex, Qt, QByteArray
import sqlite3
import os

class Task:
    def __init__(self, id=None, title="", description="", quadrant=4, is_completed=False, created_at=None):
        self.id = id
        self.title = title
        self.description = description
        self.quadrant = quadrant  # 1-4对应四个象限
        self.is_completed = is_completed
        self.created_at = created_at

class TaskModel(QAbstractListModel):
    # 定义角色
    IdRole = Qt.UserRole + 1
    TitleRole = Qt.UserRole + 2
    DescriptionRole = Qt.UserRole + 3
    QuadrantRole = Qt.UserRole + 4
    IsCompletedRole = Qt.UserRole + 5
    CreatedAtRole = Qt.UserRole + 6
    
    # 信号
    dataChanged = Signal(QModelIndex, QModelIndex, list)
    taskAdded = Signal()
    taskRemoved = Signal()
    taskMoved = Signal(int, int, arguments=["oldQuadrant", "newQuadrant"])
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.tasks = []
        self.db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "tasks.db")
        self.init_database()
        self.load_tasks()
    
    def init_database(self):
        # 确保数据目录存在
        data_dir = os.path.dirname(self.db_path)
        if not os.path.exists(data_dir):
            os.makedirs(data_dir)
        
        # 创建数据库连接和表
        conn = sqlite3.connect(self.db_path)
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
        conn.close()
    
    def load_tasks(self):
        # 从数据库加载任务
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row  # 使结果可以通过列名访问
        cursor = conn.cursor()
        
        # 只加载未完成的任务
        cursor.execute("SELECT * FROM tasks WHERE is_completed = 0 ORDER BY created_at DESC")
        rows = cursor.fetchall()
        
        self.beginResetModel()
        self.tasks = []
        for row in rows:
            task = Task(
                id=row['id'],
                title=row['title'],
                description=row['description'],
                quadrant=row['quadrant'],
                is_completed=row['is_completed'],
                created_at=row['created_at']
            )
            self.tasks.append(task)
        self.endResetModel()
        
        conn.close()
    
    def rowCount(self, parent=QModelIndex()):
        return len(self.tasks)
    
    def roleNames(self):
        roles = {
            self.IdRole: QByteArray(b'id'),
            self.TitleRole: QByteArray(b'title'),
            self.DescriptionRole: QByteArray(b'description'),
            self.QuadrantRole: QByteArray(b'quadrant'),
            self.IsCompletedRole: QByteArray(b'isCompleted'),
            self.CreatedAtRole: QByteArray(b'createdAt')
        }
        return roles
    
    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self.tasks):
            return None
        
        task = self.tasks[index.row()]
        
        if role == self.IdRole:
            return task.id
        elif role == self.TitleRole:
            return task.title
        elif role == self.DescriptionRole:
            return task.description
        elif role == self.QuadrantRole:
            return task.quadrant
        elif role == self.IsCompletedRole:
            return task.is_completed
        elif role == self.CreatedAtRole:
            return task.created_at
        
        return None
    
    @Slot(str, str, int, result=bool)
    def addTask(self, title, description, quadrant=4):
        if not title.strip():
            return False
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO tasks (title, description, quadrant) VALUES (?, ?, ?)",
            (title, description, quadrant)
        )
        task_id = cursor.lastrowid
        
        # 获取创建时间
        cursor.execute("SELECT created_at FROM tasks WHERE id = ?", (task_id,))
        created_at = cursor.fetchone()[0]
        
        conn.commit()
        conn.close()
        
        # 添加到模型
        self.beginInsertRows(QModelIndex(), 0, 0)
        new_task = Task(
            id=task_id,
            title=title,
            description=description,
            quadrant=quadrant,
            is_completed=False,
            created_at=created_at
        )
        self.tasks.insert(0, new_task)  # 添加到列表开头
        self.endInsertRows()
        
        self.taskAdded.emit()
        return True
    
    @Slot(int, bool)
    def setTaskCompleted(self, task_id, completed):
        # 在数据库中更新任务状态
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "UPDATE tasks SET is_completed = ? WHERE id = ?",
            (1 if completed else 0, task_id)
        )
        
        conn.commit()
        conn.close()
        
        # 在模型中更新任务
        for i, task in enumerate(self.tasks):
            if task.id == task_id:
                task.is_completed = completed
                index = self.createIndex(i, 0)
                self.dataChanged.emit(index, index, [self.IsCompletedRole])
                
                # 如果任务完成，从列表中移除
                if completed:
                    self.beginRemoveRows(QModelIndex(), i, i)
                    self.tasks.pop(i)
                    self.endRemoveRows()
                    self.taskRemoved.emit()
                break
    
    @Slot(int, str, str)
    def updateTask(self, task_id, title, description):
        if not title.strip():
            return
        
        # 在数据库中更新任务
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "UPDATE tasks SET title = ?, description = ? WHERE id = ?",
            (title, description, task_id)
        )
        
        conn.commit()
        conn.close()
        
        # 在模型中更新任务
        for i, task in enumerate(self.tasks):
            if task.id == task_id:
                task.title = title
                task.description = description
                index = self.createIndex(i, 0)
                self.dataChanged.emit(index, index, [self.TitleRole, self.DescriptionRole])
                break
    
    @Slot(int, int)
    def moveTaskToQuadrant(self, task_id, new_quadrant):
        if new_quadrant < 1 or new_quadrant > 4:
            return
        
        # 在数据库中更新任务象限
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 先获取旧的象限
        cursor.execute("SELECT quadrant FROM tasks WHERE id = ?", (task_id,))
        result = cursor.fetchone()
        if not result:
            conn.close()
            return
        
        old_quadrant = result[0]
        
        # 更新象限
        cursor.execute(
            "UPDATE tasks SET quadrant = ? WHERE id = ?",
            (new_quadrant, task_id)
        )
        
        conn.commit()
        conn.close()
        
        # 在模型中更新任务
        for i, task in enumerate(self.tasks):
            if task.id == task_id:
                task.quadrant = new_quadrant
                index = self.createIndex(i, 0)
                self.dataChanged.emit(index, index, [self.QuadrantRole])
                self.taskMoved.emit(old_quadrant, new_quadrant)
                break
    
    @Slot(int, result='QVariant')
    def getTasksByQuadrant(self, quadrant):
        # 获取指定象限的任务，并按order_index排序
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT * FROM tasks WHERE quadrant = ? AND is_completed = 0 ORDER BY order_index ASC, created_at DESC",
            (quadrant,)
        )
        rows = cursor.fetchall()
        conn.close()
        
        filtered_tasks = [{
            'id': row['id'],
            'title': row['title'],
            'description': row['description'],
            'quadrant': row['quadrant'],
            'order_index': row['order_index']
        } for row in rows]
        return filtered_tasks
        
    @Slot(result='QVariant')
    def getCompletedTasks(self):
        # 获取已完成的任务
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT * FROM tasks WHERE is_completed = 1 ORDER BY created_at DESC"
        )
        rows = cursor.fetchall()
        conn.close()
        
        completed_tasks = [{
            'id': row['id'],
            'title': row['title'],
            'description': row['description'],
            'quadrant': row['quadrant'],
            'created_at': row['created_at']
        } for row in rows]
        return completed_tasks
    
    @Slot()
    def refreshTasks(self):
        self.load_tasks()
    
    @Slot(int, int)
    def updateTaskOrder(self, task_id, new_order_index):
        """更新任务的排序索引"""
        if new_order_index < 0:
            return
        
        # 在数据库中更新任务排序
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 获取任务的象限
        cursor.execute("SELECT quadrant FROM tasks WHERE id = ?", (task_id,))
        result = cursor.fetchone()
        if not result:
            conn.close()
            return
        
        quadrant = result[0]
        
        # 更新排序索引
        cursor.execute(
            "UPDATE tasks SET order_index = ? WHERE id = ?",
            (new_order_index, task_id)
        )
        
        conn.commit()
        conn.close()