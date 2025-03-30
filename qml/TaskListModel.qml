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
            updateTasks()
        }
    }
    
    function updateTasks() {
        taskListModel.clear()
        var tasks = taskController.getTasksForQuadrant(quadrantNumber)
        if (!tasks || tasks.length === 0) return
        
        // 优化版 - 只在必要时排序
        if (tasks.some(task => task.order_index !== undefined)) {
            tasks.sort((a, b) => (a.order_index || 0) - (b.order_index || 0))
        }
        
        // 优化版 - 减少循环中的条件判断
        for (var i = 0; i < tasks.length; i++) {
            var task = tasks[i]
            taskListModel.append({
                "id": task.id,
                "title": task.title,
                "description": task.description || "",
                "quadrant": task.quadrant,
                "order_index": task.order_index || i
            })
        }
    }
}