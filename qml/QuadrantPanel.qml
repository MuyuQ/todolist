import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: quadrantPanel
    
    property int quadrantNumber: 1
    property string quadrantTitle: "象限"
    property color quadrantColor: "#4361ee"
    
    color: "white"
    radius: 16
    border.width: 1
    border.color: "#e9ecef"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 象限标题栏
        Rectangle {
            Layout.fillWidth: true
            height: 52
            color: "white"
            border.width: 0
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#e9ecef"
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8
                
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: quadrantColor
                }
                
                Text {
                    text: quadrantTitle
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "#2b2d42"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    id: taskCount
                    text: "0"
                    font.pixelSize: 14
                    color: "#8d99ae"
                }
            }
        }
        
        // 任务列表
        ListView {
            id: taskListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            // 添加clip属性确保内容不会溢出到四象限面板边界外
            clip: true
            model: taskController.getTasksForQuadrant(quadrantNumber)
            delegate: TaskItem {
                // 使用ListView.view.width而不是直接引用taskListView.width
                width: ListView.view.width
                quadrantColor: quadrantPanel.quadrantColor
            }
            spacing: 1
            
            // 空列表占位符 - 使用Item作为容器确保正确布局
            Item {
                id: emptyPlaceholder
                // 确保占位符覆盖整个列表视图区域
                anchors.fill: parent
                visible: taskListView.count === 0
                // 设置z值确保占位符显示在最上层
                z: 10
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "📝"
                        font.pixelSize: 32
                    }
                    
                    Text {
                        text: qsTr("暂无任务")
                        font.pixelSize: 14
                        color: "#8d99ae"
                    }
                }
            }
            
            ScrollBar.vertical: ScrollBar {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.topMargin: 6
                anchors.bottomMargin: 6
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: "#e9ecef"
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 2
                        color: "#8d99ae"
                    }
                }
            }
        }
    }
    
    // 更新任务计数
    function updateTaskCount() {
        taskCount.text = taskListView.count
    }
    
    // 监听任务列表变化
    Connections {
        target: taskController
        function onTaskUpdated() {
            updateTaskCount()
        }
    }
    
    Component.onCompleted: {
        updateTaskCount()
    }
}