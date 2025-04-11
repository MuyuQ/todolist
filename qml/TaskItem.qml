import QtQuick 2.15  // Qt Quick核心模块
import QtQuick.Controls 2.15  // Qt Quick控件模块
import QtQuick.Layouts 1.15  // 布局管理模块

// 任务项组件
// 用于在列表中显示单个任务，包含任务信息和操作按钮
Rectangle {
    id: taskDelegate  // 组件ID
    height: 80  // 固定高度
    radius: 12  // 圆角半径
    color: "white"  // 背景色
    border.width: 0  // 无边框
    
    // 使用统一的阴影效果组件
    ShadowEffect {
        id: shadowEffect
        offsetY: 3
        blurRadius: 8.0
        shadowColor: "#25000000"
        animated: true
        Component.onCompleted: applyTo(taskDelegate)
    }
    
    // 渐变背景
    Rectangle {
        id: gradientBackground
        anchors.fill: parent
        radius: parent.radius
        opacity: 0.05
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(Material.accent, 1.1) }
            GradientStop { position: 1.0; color: "white" }
        }
    }
    
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    
    Component.onCompleted: {
        consoleLogger.log("TaskItem创建: ID=" + taskId + ", 标题=" + taskTitle)
    }
    
    // 统一动画效果
    Behavior on scale { NumberAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    
    // 任务内容
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Label {
                    text: taskTitle
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                // 任务描述标签
                Label {
                    text: taskDescription
                    font.pixelSize: 12
                    color: "#666666"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: taskDescription && taskDescription.length > 0
                    maximumLineCount: 1
                }
            }
            
            // 完全重构CheckBox布局
            Item {
                // 使用Item作为容器，确保CheckBox垂直居中
                Layout.preferredWidth: taskCheckBox.width + 10
                Layout.fillHeight: true
                
                CheckBox {
                    id: taskCheckBox
                    checked: false
                    onClicked: {
                        consoleLogger.log("点击任务ID: " + taskId + " 状态: " + checked)
                        if (taskId > 0) {
                            consoleLogger.log("调用setTaskCompleted: " + taskId + ", " + checked)
                            taskController.setTaskCompleted(taskId, checked)
                        } else {
                            consoleLogger.log("错误: 无效的任务ID")
                        }
                    }
                    anchors.centerIn: parent  // 在容器中完全居中
                    
                    enabled: true
                    
                    indicator: Rectangle {
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 4
                        // 简化颜色逻辑
                        border.color: taskCheckBox.checked ? "#0078d4" : 
                                     taskCheckBox.hovered ? "#666666" : "#999999"
                        border.width: 1.5
                        color: taskCheckBox.checked ? "#0078d4" : "transparent"
                        
                        // 添加过渡动画
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            text: "✓"
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: 14
                            // 简化可见性和透明度逻辑
                            visible: taskCheckBox.checked
                            opacity: taskCheckBox.checked ? 1.0 : 0.0
                            
                            // 添加过渡动画
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }
                }
                
                // CheckBox已经有自己的鼠标处理，不需要额外的MouseArea
            }
        }
    }
}