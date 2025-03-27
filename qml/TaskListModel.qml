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
        if (tasks && tasks.length > 0) {
            // 按照order_index排序
            tasks.sort(function(a, b) {
                return a.order_index - b.order_index // 升序排列，按照order_index
            })
            
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i]
                taskListModel.append({
                    "id": task.id,
                    "title": task.title,
                    "description": task.description,
                    "quadrant": task.quadrant,
                    "order_index": task.order_index || i // 使用order_index或默认索引
                })
            }
        }
    }
}