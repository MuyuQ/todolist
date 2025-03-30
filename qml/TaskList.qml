import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    color: "white"
    radius: 8
    
    // 阴影效果 - 优化版
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 12
        color: "#20000000"
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
            
            model: taskController.getAllTasks()
            
            Connections {
                target: taskController
                function onTaskUpdated() {
                    taskList.model = taskController.getAllTasks()
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