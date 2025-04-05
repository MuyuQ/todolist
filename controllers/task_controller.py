from PySide6.QtCore import QObject, Signal, Slot

class TaskController(QObject):
    """任务控制器类
    
    负责处理任务的业务逻辑，作为模型层和视图层之间的桥梁。
    提供了一系列槽函数，可以从QML界面调用，用于操作任务数据。
    
    Attributes:
        taskUpdated: 任务更新信号，当任务数据发生变化时发出，通知UI更新
        task_model: 关联的任务数据模型实例
    """
    
    # 信号 - 当任务数据变化时通知UI更新
    taskUpdated = Signal()
    
    def __init__(self, task_model, parent=None):
        """初始化任务控制器
        
        Args:
            task_model: 任务数据模型实例，控制器将操作此模型
            parent: 父QObject对象，用于Qt对象树管理
        """
        super().__init__(parent)
        self.task_model = task_model  # 存储对任务模型的引用
        
    def _emit_update(self):
        """辅助方法：发出任务更新信号
        
        当任务数据发生变化时，调用此方法通知UI进行更新。
        注意：此方法应该只在确实需要更新UI时调用，避免不必要的更新。
        """
        self.taskUpdated.emit()  # 发出信号，通知UI更新
    
    @Slot(str, str, int)
    def addTask(self, title, description, quadrant=4):
        """添加新任务
        
        创建一个新的任务并添加到数据模型中。
        
        Args:
            title: 任务标题
            description: 任务描述
            quadrant: 任务所属象限(1-4)，默认为第4象限(不重要不紧急)
            
        Returns:
            bool: 添加是否成功
        """
        success = self.task_model.addTask(title, description, quadrant)
        if success:
            self._emit_update()  # 添加成功后通知UI更新
        return success
    
    @Slot(int, bool)
    def setTaskCompleted(self, task_id, completed=True):
        """设置任务完成状态
        
        将指定ID的任务标记为完成或未完成。
        
        Args:
            task_id: 任务ID
            completed: 是否完成，True表示完成，False表示未完成
        """
        self.task_model.setTaskCompleted(task_id, completed)
        self._emit_update()  # 状态变更后通知UI更新
    
    @Slot(int, str, str)
    def updateTask(self, task_id, title, description):
        """更新任务信息
        
        修改指定ID任务的标题和描述。
        
        Args:
            task_id: 任务ID
            title: 新的任务标题
            description: 新的任务描述
        """
        self.task_model.updateTask(task_id, title, description)
        self._emit_update()  # 更新后通知UI刷新
    
    @Slot(int, int)
    def moveTaskToQuadrant(self, task_id, new_quadrant):
        """移动任务到新象限
        
        将任务从当前象限移动到新的象限。
        
        Args:
            task_id: 任务ID
            new_quadrant: 新的象限编号(1-4)
        """
        self.task_model.moveTaskToQuadrant(task_id, new_quadrant)
        self._emit_update()  # 移动后通知UI更新
    
    @Slot()
    def refreshTasks(self):
        """刷新任务列表
        
        从数据库重新加载所有任务数据，用于确保UI显示的是最新数据。
        通常在应用启动时或需要强制刷新数据时调用。
        """
        self.task_model.refreshTasks()
        self._emit_update()  # 刷新后通知UI更新
    
    @Slot(int, result='QVariant')
    def getTasksForQuadrant(self, quadrant):
        """获取指定象限的任务列表
        
        返回特定象限的所有未完成任务。
        
        Args:
            quadrant: 象限编号(1-4)
            
        Returns:
            QVariant: 包含任务数据的列表，可在QML中使用
        """
        return self.task_model.getTasksByQuadrant(quadrant)
    
    @Slot(result='QVariant')
    def getAllTasks(self):
        """获取所有任务列表
        
        返回所有未完成的任务，按象限组织。
        
        Returns:
            QVariant: 包含所有任务数据的列表，可在QML中使用
        """
        # 直接从模型获取所有任务，按象限组织
        all_tasks = []
        for quadrant in range(1, 5):  # 遍历四个象限
            tasks = self.task_model.getTasksByQuadrant(quadrant)
            all_tasks.extend(tasks)  # 将每个象限的任务添加到结果列表
        return all_tasks
    
    @Slot(result='QVariant')
    def getCompletedTasks(self):
        """获取已完成任务列表
        
        返回所有已标记为完成的任务。
        
        Returns:
            QVariant: 包含已完成任务数据的列表，可在QML中使用
        """
        return self.task_model.getCompletedTasks()
    
    @Slot(int, int)
    def updateTaskOrder(self, task_id, new_order_index):
        """更新任务排序
        
        更改任务在列表中的显示顺序。
        
        Args:
            task_id: 任务ID
            new_order_index: 新的排序索引
        """
        self.task_model.updateTaskOrder(task_id, new_order_index)
        self._emit_update()  # 排序变更后通知UI更新