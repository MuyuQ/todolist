from PySide6.QtCore import QObject, Signal, Slot

class TaskController(QObject):
    # 信号
    taskUpdated = Signal()
    
    def __init__(self, task_model, parent=None):
        super().__init__(parent)
        self.task_model = task_model
        
    def _emit_update(self):
        """辅助方法：发出任务更新信号
        注意：此方法应该只在确实需要更新UI时调用，避免不必要的更新
        """
        self.taskUpdated.emit()
    
    @Slot(str, str, int)
    def addTask(self, title, description, quadrant=4):
        """添加新任务"""
        success = self.task_model.addTask(title, description, quadrant)
        if success:
            self._emit_update()
        return success
    
    @Slot(int, bool)
    def setTaskCompleted(self, task_id, completed=True):
        """设置任务完成状态"""
        self.task_model.setTaskCompleted(task_id, completed)
        self._emit_update()
    
    @Slot(int, str, str)
    def updateTask(self, task_id, title, description):
        """更新任务信息"""
        self.task_model.updateTask(task_id, title, description)
        self._emit_update()
    
    @Slot(int, int)
    def moveTaskToQuadrant(self, task_id, new_quadrant):
        """移动任务到新象限"""
        self.task_model.moveTaskToQuadrant(task_id, new_quadrant)
        self._emit_update()
    
    @Slot()
    def refreshTasks(self):
        """刷新任务列表"""
        self.task_model.refreshTasks()
        self._emit_update()
    
    @Slot(int, result='QVariant')
    def getTasksForQuadrant(self, quadrant):
        """获取指定象限的任务列表"""
        return self.task_model.getTasksByQuadrant(quadrant)
    
    @Slot(result='QVariant')
    def getAllTasks(self):
        """获取所有任务列表"""
        # 直接从模型获取所有任务，按象限组织
        all_tasks = []
        for quadrant in range(1, 5):
            tasks = self.task_model.getTasksByQuadrant(quadrant)
            all_tasks.extend(tasks)
        return all_tasks
    
    @Slot(result='QVariant')
    def getCompletedTasks(self):
        """获取已完成任务列表"""
        return self.task_model.getCompletedTasks()
    
    @Slot(int, int)
    def updateTaskOrder(self, task_id, new_order_index):
        """更新任务排序"""
        self.task_model.updateTaskOrder(task_id, new_order_index)
        self._emit_update()