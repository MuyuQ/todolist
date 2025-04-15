import QtQuick 2.15

Item {
    id: root
    property int quadrantNumber: 1
    property alias model: taskListModel
    
    ListModel {
        id: taskListModel
    }
    
    Component.onCompleted: {
        updateTasks()
    }
    
    Connections {
        target: taskController
        function onTaskUpdated() {
            // 只更新当前象限的任务，避免重复加载
            updateTasks()
        }
    }
    
    function updateTasks() {
        // 清空模型前先记录当前数量
        var oldCount = taskListModel.count
        taskListModel.clear()
        
        var tasks = taskController.getTasksForQuadrant(quadrantNumber)
        if (!tasks || tasks.length === 0) return
        
        // 按order_index排序
        tasks.sort((a, b) => (a.order_index || 0) - (b.order_index || 0))
        
        // 添加到列表模型 - 包括已完成和未完成的任务
        for (var i = 0; i < tasks.length; i++) {
            var task = tasks[i]
            // 不再跳过已完成的任务，让它们也显示在四象限视图中
            
            taskListModel.append({
                "id": task.id,
                "title": task.title,
                "description": task.description || "",
                "quadrant": task.quadrant,
                "isCompleted": task.isCompleted || false
            })
        }
        
        // 输出调试信息 - 使用consoleLogger确保中文正确显示
        consoleLogger.log("象限 " + quadrantNumber + " 更新: 原有 " + oldCount + " 个任务，现有 " + taskListModel.count + " 个任务")
    }
}