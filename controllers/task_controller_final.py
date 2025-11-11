from PySide6.QtCore import QObject, Signal, Slot

class TaskController(QObject):
    taskUpdated = Signal()
    
    def __init__(self, task_model, parent=None):
        super().__init__(parent)
        self.task_model = task_model
    
    def _emit_update(self):
        self.taskUpdated.emit()
    
    @Slot(str, str, int)
    def addTask(self, title, description, quadrant=4):
        success = self.task_model.addTask(title, description, quadrant)
        if success:
            self._emit_update()
        return success
    
    @Slot(int, bool)
    def setTaskCompleted(self, task_id, completed=True):
        self.task_model.setTaskCompleted(task_id, completed)
        self._emit_update()
    
    @Slot(int, str, str)
    def updateTask(self, task_id, title, description):
        self.task_model.updateTask(task_id, title, description)
        self._emit_update()
    
    @Slot(int, int)
    def moveTaskToQuadrant(self, task_id, new_quadrant):
        self.task_model.moveTaskToQuadrant(task_id, new_quadrant)
        self._emit_update()
    
    @Slot()
    def refreshTasks(self):
        self.task_model.refreshTasks()
        self._emit_update()
    
    @Slot(int, result='QVariant')
    def getTasksForQuadrant(self, quadrant):
        return self.task_model.getTasksByQuadrant(quadrant)
    
    @Slot(result='QVariant')
    def getAllTasks(self):
        all_tasks = []
        for quadrant in range(1, 5):
            tasks = self.task_model.getTasksByQuadrant(quadrant)
            all_tasks.extend(tasks)
        return all_tasks
    
    @Slot(result='QVariant')
    def getCompletedTasks(self):
        return self.task_model.getCompletedTasks()
    
    @Slot(int, int)
    def updateTaskOrder(self, task_id, new_order_index):
        self.task_model.updateTaskOrder(task_id, new_order_index)
        self._emit_update()