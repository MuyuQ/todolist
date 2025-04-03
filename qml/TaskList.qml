import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "white"
    radius: 8
    
    // 使用统一的阴影效果组件
    ShadowEffect {
        id: shadowEffect
        offsetY: 2
        blurRadius: 8.0
        shadowColor: "#20000000"
        Component.onCompleted: applyTo(root)
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8
        
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#f5f5f5"
            radius: 4
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                
                Label {
                    text: "所有任务"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Label {
                    text: taskList.count + " 个任务"
                    font.pixelSize: 14
                    color: "#666666"
                }
            }
        }
        
        ListView {
            id: taskList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            
            // 使用ListModel来管理任务数据
            model: ListModel { id: allTasksModel }
            
            Component.onCompleted: {
                updateTaskList()
            }
            
            Connections {
                target: taskController
                function onTaskUpdated() {
                    updateTaskList()
                }
            }
            
            // 更新任务列表函数
            function updateTaskList() {
                allTasksModel.clear()
                var tasks = taskController.getAllTasks()
                for (var i = 0; i < tasks.length; i++) {
                    allTasksModel.append(tasks[i])
                }
            }

            delegate: TaskItem {
                width: taskList.width
                taskId: model.id
                taskTitle: model.title
                taskDescription: model.description
                taskQuadrant: model.quadrant
            }
            
            ScrollBar.vertical: ScrollBar {}
        }
    }
}