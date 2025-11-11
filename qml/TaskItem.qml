import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: taskItem
    
    // 使用数据模型中实际返回的字段名
    property int id: -1
    property string title: ""
    property string description: ""
    property int quadrant: 1
    property bool isCompleted: false
    property color quadrantColor: "#4361ee"
    
    // 设置最小高度以确保足够的显示空间
    implicitHeight: contentLayout.implicitHeight + 24
    color: "white"
    
    // 拖放相关属性
    property bool dragActive: false
    property point dragStart
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        // 确保列布局不会溢出父容器
        Layout.fillWidth: true
        
        RowLayout {
            spacing: 8
            
            // 完成复选框
            Rectangle {
                id: checkbox
                width: 20
                height: 20
                radius: 10
                border.width: 2
                border.color: quadrantColor
                color: isCompleted ? quadrantColor : "white"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                    taskController.setTaskCompleted(id, !isCompleted)
                }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 12
                    color: "white"
                    visible: isCompleted
                }
            }
            
            // 任务标题
            Text {
                text: title || "(无标题任务)"
                font.pixelSize: 16
                font.weight: Font.Medium
                // 使用更明显的颜色确保文本可见
                color: isCompleted ? "#8d99ae" : "#2b2d42"
                elide: Text.ElideRight
                Layout.fillWidth: true
                // 移除不支持的minimumWidth属性，Text组件不支持此属性
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        editTaskDialog.open(id, title, description, quadrant)
                    }
                }
            }
        }
        
        // 任务描述
        Text {
            text: description
            font.pixelSize: 14
            color: "#8d99ae"
            elide: Text.ElideRight
            Layout.fillWidth: true
            visible: description.length > 0
        }
        
        // 操作按钮区域
        RowLayout {
            spacing: 8
            
            Item { Layout.fillWidth: true }
            
            // 移动按钮
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "#f8f9fa"
                
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        dragActive = true
                        dragStart = Qt.point(mouseX, mouseY)
                    }
                    onReleased: {
                        dragActive = false
                    }
                    onPositionChanged: {
                        if (dragActive) {
                            // 这里可以实现拖动功能
                        }
                    }
                    cursorShape: Qt.OpenHandCursor
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "⋮⋮"
                    font.pixelSize: 12
                    color: "#8d99ae"
                }
            }
            
            // 编辑按钮
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "#f8f9fa"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        editTaskDialog.open(id, title, description, quadrant)
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✎"
                    font.pixelSize: 12
                    color: "#8d99ae"
                }
            }
        }
    }
    
    // 悬停效果
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            taskItem.color = "#f8f9fa"
        }
        onExited: {
            taskItem.color = "white"
        }
    }
    
    // 数据属性已在组件顶部定义
}