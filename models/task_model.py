from PySide6.QtCore import QObject, Signal, Property, Slot, QAbstractListModel, QModelIndex, Qt, QByteArray  # Qt核心组件
import sqlite3  # SQLite数据库接口
import os  # 操作系统接口，用于文件路径处理

class Task:
    """任务数据类
    
    表示单个任务的数据结构，包含任务的所有属性。
    
    Attributes:
        id: 任务唯一标识符
        title: 任务标题
        description: 任务描述
        quadrant: 任务所属象限(1-4)
        is_completed: 任务是否已完成
        created_at: 任务创建时间
    """
    
    def __init__(self, id=None, title="", description="", quadrant=4, is_completed=False, created_at=None):
        """初始化任务对象
        
        Args:
            id: 任务ID，默认为None（新任务）
            title: 任务标题，默认为空字符串
            description: 任务描述，默认为空字符串
            quadrant: 任务所属象限，默认为4（不重要不紧急）
            is_completed: 任务是否已完成，默认为False
            created_at: 任务创建时间，默认为None（将由数据库设置）
        """
        self.id = id
        self.title = title
        self.description = description
        self.quadrant = quadrant  # 1-4对应四个象限
        self.is_completed = is_completed
        self.created_at = created_at

class TaskModel(QAbstractListModel):
    """任务数据模型
    
    管理任务数据并提供与QML界面交互的接口。
    继承自QAbstractListModel，实现了Qt的模型-视图架构。
    负责任务数据的CRUD操作和持久化存储。
    
    Attributes:
        tasks: 任务对象列表
        db_path: 数据库文件路径
    """
    
    # 定义数据角色，用于QML访问模型数据
    IdRole = Qt.UserRole + 1  # 任务ID角色
    TitleRole = Qt.UserRole + 2  # 任务标题角色
    DescriptionRole = Qt.UserRole + 3  # 任务描述角色
    QuadrantRole = Qt.UserRole + 4  # 任务象限角色
    IsCompletedRole = Qt.UserRole + 5  # 任务完成状态角色
    CreatedAtRole = Qt.UserRole + 6  # 任务创建时间角色
    
    # 信号定义
    dataChanged = Signal(QModelIndex, QModelIndex, list)  # 数据变更信号
    taskAdded = Signal()  # 任务添加信号
    taskRemoved = Signal()  # 任务移除信号
    taskMoved = Signal(int, int, arguments=["oldQuadrant", "newQuadrant"])  # 任务移动信号
    
    def __init__(self, parent=None):
        """初始化任务模型
        
        Args:
            parent: 父QObject对象，用于Qt对象树管理
        """
        super().__init__(parent)
        self.tasks = []  # 初始化任务列表
        # 设置数据库路径为应用程序目录下的data/tasks.db
        self.db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "tasks.db")
        self.init_database()  # 初始化数据库
        self.load_tasks()  # 加载任务数据
    
    def init_database(self):
        """初始化数据库
        
        确保数据目录存在，创建数据库连接，并初始化任务表结构。
        如果表已存在，检查是否需要添加新列。
        """
        # 确保数据目录存在
        data_dir = os.path.dirname(self.db_path)
        if not os.path.exists(data_dir):
            os.makedirs(data_dir)  # 创建数据目录
        
        # 创建数据库连接和表
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 创建任务表，如果不存在
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,  -- 任务ID，自动递增
            title TEXT NOT NULL,                  -- 任务标题，不允许为空
            description TEXT,                     -- 任务描述
            quadrant INTEGER DEFAULT 4,           -- 任务象限，默认为4
            is_completed BOOLEAN DEFAULT 0,       -- 完成状态，默认未完成
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 创建时间
            order_index INTEGER DEFAULT 0         -- 排序索引
        )
        ''')
        
        # 检查是否需要添加order_index列（兼容旧版本数据库）
        cursor.execute("PRAGMA table_info(tasks)")
        columns = cursor.fetchall()
        has_order_index = any(column[1] == 'order_index' for column in columns)
        
        # 如果没有order_index列，添加它
        if not has_order_index:
            cursor.execute("ALTER TABLE tasks ADD COLUMN order_index INTEGER DEFAULT 0")
        
        conn.commit()  # 提交事务
        conn.close()  # 关闭连接
    
    def _get_db_connection(self):
        """获取数据库连接
        
        创建并返回一个配置好的数据库连接对象，减少代码冗余。
        设置row_factory为sqlite3.Row，使查询结果可以通过列名访问。
        
        Returns:
            sqlite3.Connection: 配置好的数据库连接对象
        """
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row  # 使结果可以通过列名访问
        return conn
    
    def load_tasks(self):
        """从数据库加载任务
        
        从数据库中检索所有未完成的任务，并更新模型数据。
        使用beginResetModel和endResetModel通知视图模型数据已完全重置。
        """
        # 从数据库加载任务
        conn = self._get_db_connection()
        cursor = conn.cursor()
        
        # 只加载未完成的任务，按创建时间降序排列
        cursor.execute("SELECT * FROM tasks WHERE is_completed = 0 ORDER BY created_at DESC")
        rows = cursor.fetchall()
        
        # 开始重置模型，通知视图数据将要改变
        self.beginResetModel()
        self.tasks = []
        # 将数据库记录转换为Task对象
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
        # 结束重置模型，通知视图数据已改变
        self.endResetModel()
        
        conn.close()  # 关闭数据库连接
    
    def rowCount(self, parent=QModelIndex()):
        """返回模型中的行数（任务数量）
        
        实现QAbstractListModel的必要方法，用于告诉视图有多少行数据。
        
        Args:
            parent: 父索引，对于列表模型通常忽略
            
        Returns:
            int: 任务列表中的任务数量
        """
        return len(self.tasks)
    
    def roleNames(self):
        """定义角色名称映射
        
        实现QAbstractListModel的方法，将角色ID映射到QML中可用的属性名。
        这使得QML可以通过属性名访问模型数据，如model.title。
        
        Returns:
            dict: 角色ID到角色名称的映射字典
        """
        roles = {
            self.IdRole: QByteArray(b'id'),               # 任务ID
            self.TitleRole: QByteArray(b'title'),         # 任务标题
            self.DescriptionRole: QByteArray(b'description'),  # 任务描述
            self.QuadrantRole: QByteArray(b'quadrant'),    # 任务象限
            self.IsCompletedRole: QByteArray(b'isCompleted'),  # 完成状态
            self.CreatedAtRole: QByteArray(b'createdAt')   # 创建时间
        }
        return roles
    
    def data(self, index, role=Qt.DisplayRole):
        """获取指定索引和角色的数据
        
        实现QAbstractListModel的必要方法，根据给定的索引和角色返回相应的数据。
        这是QML视图获取模型数据的主要方法。
        
        Args:
            index: 模型索引，指定要获取的数据项
            role: 数据角色，指定要获取的数据类型
            
        Returns:
            任务的相应属性值，如果索引无效或角色不匹配则返回None
        """
        # 检查索引是否有效
        if not index.isValid() or index.row() >= len(self.tasks):
            return None
        
        # 获取指定索引的任务
        task = self.tasks[index.row()]
        
        # 根据角色返回相应的数据
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
        """添加新任务
        
        创建一个新的任务并将其添加到数据库中。
        此方法可从QML中调用，用于创建新任务。
        
        Args:
            title: 任务标题
            description: 任务描述
            quadrant: 任务所属象限(1-4)，默认为第4象限(不重要不紧急)
            
        Returns:
            bool: 添加是否成功，如果标题为空则返回False
        """
        # 验证标题不为空（必填字段）
        if not title.strip():
            return False
        
        # 获取数据库连接
        conn = self._get_db_connection()
        cursor = conn.cursor()
        
        # 将任务插入数据库
        cursor.execute(
            "INSERT INTO tasks (title, description, quadrant) VALUES (?, ?, ?)",
            (title, description, quadrant)
        )
        task_id = cursor.lastrowid  # 获取新插入任务的ID
        
        # 获取数据库自动生成的创建时间
        cursor.execute("SELECT created_at FROM tasks WHERE id = ?", (task_id,))
        created_at = cursor.fetchone()[0]
        
        # 提交事务并关闭连接
        conn.commit()
        conn.close()
        
        # 添加到内存中的模型（在列表开头插入）
        # beginInsertRows通知视图即将插入新行
        self.beginInsertRows(QModelIndex(), 0, 0)
        # 创建新的Task对象
        new_task = Task(
            id=task_id,
            title=title,
            description=description,
            quadrant=quadrant,
            is_completed=False,
            created_at=created_at
        )
        self.tasks.insert(0, new_task)  # 添加到列表开头，使新任务显示在最前面
        self.endInsertRows()  # 通知视图行插入已完成
        
        # 发出任务添加信号，通知其他组件（如控制器）
        self.taskAdded.emit()
        
        return True  # 返回成功标志
    
    @Slot(int, bool)
    def setTaskCompleted(self, task_id, completed=True):
        """设置任务完成状态
        
        将指定ID的任务标记为完成或未完成。
        完成的任务将从活动任务列表中移除，并显示在已完成任务列表中。
        
        Args:
            task_id: 要更新的任务ID
            completed: 是否完成，True表示完成，False表示未完成
        """
        # 更新数据库中的任务状态
        conn = self._get_db_connection()
        cursor = conn.cursor()
        
        # 执行SQL更新操作
        cursor.execute(
            "UPDATE tasks SET is_completed = ? WHERE id = ?",
            (1 if completed else 0, task_id)  # SQLite中布尔值用0/1表示
        )
        
        # 提交事务并关闭连接
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
        conn = self._get_db_connection()
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
        conn = self._get_db_connection()
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
        conn = self._get_db_connection()
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
        conn = self._get_db_connection()
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