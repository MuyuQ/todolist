import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: taskDelegate
    height: 80
    radius: 12
    color: "white"
    border.width: 0
    
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
            GradientStop { position: 0.0; color: Qt.lighter(parent.parent.Material.accent, 1.1) }
            GradientStop { position: 1.0; color: "white" }
        }
    }
    
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    
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
            
            CheckBox {
                id: taskCheckBox
                checked: false
                onClicked: taskController.setTaskCompleted(taskId, checked)
                
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
                
                // CheckBox已经有自己的鼠标处理，不需要额外的MouseArea
            }
        }
    }
}