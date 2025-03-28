from PySide6.QtCore import QObject, Signal, Slot

class TaskController(QObject):
    # 信号
    taskUpdated = Signal()
    
    def __init__(self, task_model, parent=None):
        super().__init__(parent)
        self.task_model = task_model
    
    @Slot(str, str, int)
    def addTask(self, title, description, quadrant=4):
        """添加新任务"""
        success = self.task_model.addTask(title, description, quadrant)
        if success:
            self.taskUpdated.emit()
        return success
    
    @Slot(int, bool)
    def setTaskCompleted(self, task_id, completed=True):
        """设置任务完成状态"""
        self.task_model.setTaskCompleted(task_id, completed)
        self.taskUpdated.emit()
    
    @Slot(int, str, str)
    def updateTask(self, task_id, title, description):
        """更新任务信息"""
        self.task_model.updateTask(task_id, title, description)
        self.taskUpdated.emit()
    
    @Slot(int, int)
    def moveTaskToQuadrant(self, task_id, new_quadrant):
        """移动任务到新象限"""
        self.task_model.moveTaskToQuadrant(task_id, new_quadrant)
        self.taskUpdated.emit()
    
    @Slot()
    def refreshTasks(self):
        """刷新任务列表"""
        self.task_model.refreshTasks()
        self.taskUpdated.emit()
    
    @Slot(int, result='QVariant')
    def getTasksForQuadrant(self, quadrant):
        """获取指定象限的任务列表"""
        return self.task_model.getTasksByQuadrant(quadrant)
    
    @Slot(result='QVariant')
    def getAllTasks(self):
        """获取所有任务列表"""
        return self.task_model
    
    @Slot(result='QVariant')
    def getCompletedTasks(self):
        """获取已完成任务列表"""
        return self.task_model.getCompletedTasks()
    
    @Slot(int, int)
    def updateTaskOrder(self, task_id, new_order_index):
        """更新任务排序"""
        self.task_model.updateTaskOrder(task_id, new_order_index)
        self.taskUpdated.emit()