from PySide6.QtCore import QObject, Signal, Property, Slot, QAbstractListModel, QModelIndex, Qt, QByteArray
from .db_manager import DatabaseManager

class Task:
    """任务数据模型类"""
    def __init__(self, id=None, title="", description="", quadrant=4, is_completed=False, created_at=None, order_index=0):
        self.id = id
        self.title = title
        self.description = description
        self.quadrant = quadrant  # 1-4对应四个象限
        self.is_completed = is_completed
        self.created_at = created_at
        self.order_index = order_index

class TaskModel(QAbstractListModel):
    # 定义角色
    IdRole = Qt.UserRole + 1
    TitleRole = Qt.UserRole + 2
    DescriptionRole = Qt.UserRole + 3
    QuadrantRole = Qt.UserRole + 4
    IsCompletedRole = Qt.UserRole + 5
    CreatedAtRole = Qt.UserRole + 6
    OrderIndexRole = Qt.UserRole + 7
    
    # 信号
    dataChanged = Signal(QModelIndex, QModelIndex, list)
    taskAdded = Signal()
    taskRemoved = Signal()
    taskMoved = Signal(int, int, arguments=["oldQuadrant", "newQuadrant"])
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.tasks = []
        self.db = DatabaseManager()
        self.load_tasks()
    
    def load_tasks(self):
        """从数据库加载任务"""
        rows = self.db.get_all_tasks(completed=False)
        
        self.beginResetModel()
        self.tasks = []
        if rows:
            for row in rows:
                task = Task(
                    id=row['id'],
                    title=row['title'],
                    description=row['description'],
                    quadrant=row['quadrant'],
                    is_completed=row['is_completed'],
                    created_at=row['created_at'],
                    order_index=row['order_index']
                )
                self.tasks.append(task)
        self.endResetModel()
    
    def rowCount(self, parent=QModelIndex()):
        return len(self.tasks)
    
    def roleNames(self):
        roles = {
            self.IdRole: QByteArray(b'id'),
            self.TitleRole: QByteArray(b'title'),
            self.DescriptionRole: QByteArray(b'description'),
            self.QuadrantRole: QByteArray(b'quadrant'),
            self.IsCompletedRole: QByteArray(b'isCompleted'),
            self.CreatedAtRole: QByteArray(b'createdAt'),
            self.OrderIndexRole: QByteArray(b'orderIndex')
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
        elif role == self.OrderIndexRole:
            return task.order_index
        
        return None
    
    @Slot(str, str, int, result=bool)
    def addTask(self, title, description, quadrant=4):
        """添加新任务"""
        if not title.strip():
            return False
        
        # 插入任务到数据库
        task_id = self.db.add_task(title, description, quadrant)
        
        # 获取创建时间
        created_at_row = self.db.execute_query(
            "SELECT created_at FROM tasks WHERE id = ?", 
            (task_id,)
        )
        created_at = created_at_row['created_at'] if created_at_row else None
        
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
        """设置任务完成状态"""
        # 在数据库中更新任务状态
        self.db.set_task_completed(task_id, completed)
        
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
        """更新任务信息"""
        if not title.strip():
            return
        
        # 在数据库中更新任务
        self.db.update_task(task_id, title, description)
        
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
        """移动任务到新象限"""
        if new_quadrant < 1 or new_quadrant > 4:
            return
        
        # 更新象限并获取旧象限
        success, old_quadrant = self.db.move_task_to_quadrant(task_id, new_quadrant)
        
        if not success or old_quadrant is None:
            return
        
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
        """获取指定象限的任务"""
        # 获取指定象限的任务，并按order_index排序
        rows = self.db.get_tasks_by_quadrant(quadrant)
        
        if not rows:
            return []
        
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
        """获取已完成的任务"""
        rows = self.db.get_all_tasks(completed=True)
        
        if not rows:
            return []
        
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
        """刷新任务列表"""
        self.load_tasks()
    
    @Slot(int, int)
    def updateTaskOrder(self, task_id, new_order_index):
        """更新任务的排序索引"""
        if new_order_index < 0:
            return
        
        # 更新排序索引
        self.db.update_task_order(task_id, new_order_index)