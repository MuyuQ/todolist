import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

// 导入单例
import "." as App

BaseDialog {
    id: addTaskDialog
    title: "创建新任务"
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    // 直接使用全局单例Utils

    property string taskTitle: ""
    property string taskDescription: ""
    property int selectedQuadrant: 4

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 24

        // 任务标题输入框
        InputField {
            id: titleField
            label: "任务标题"
            placeholderText: "请输入任务标题"
            onTextEdited: taskTitle = text
        }

        // 任务描述输入框
        InputField {
            id: descriptionField
            label: "任务描述"
            placeholderText: "请输入任务描述（可选）"
            isTextArea: true
            Layout.fillHeight: true
            onTextEdited: taskDescription = text
        }

        // 象限选择
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Label {
                text: "选择任务象限"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Material.foreground
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#f5f5f5"
                radius: 8
                border.width: 1
                border.color: "#e0e0e0"
                
                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 16
                    
                    Repeater {
                        model: 4
                
                         RadioButton {
                    id: quadrantRadio
                    // 使用CommonStyles中的象限标题和颜色
                    
                    text: CommonStyles.colors.quadrantTitles[index]
                    checked: index + 1 === selectedQuadrant
                    onClicked: selectedQuadrant = index + 1
                    padding: 8
                    
                    indicator: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        x: quadrantRadio.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 10
                        color: "transparent"
                        border.color: quadrantRadio.checked ? Material.accent : "#9e9e9e"
                        border.width: 2
                        
                        Rectangle {
                            width: 10
                            height: 10
                            anchors.centerIn: parent
                            radius: 5
                            color: CommonStyles.colors.quadrantColors[index]
                            visible: quadrantRadio.checked
                            
                            // 添加选中动画
                            Behavior on width {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                    
                    contentItem: RowLayout {
                        spacing: 12
                        anchors.left: quadrantRadio.indicator.right
                        anchors.leftMargin: 12
                        anchors.right: quadrantRadio.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 4
                            color: CommonStyles.colors.quadrantColors[index]
                            opacity: 0.8
                        }
                        
                        Text {
                            text: quadrantRadio.text
                            font.pixelSize: 14
                            font.weight: quadrantRadio.checked ? Font.Medium : Font.Normal
                            color: quadrantRadio.checked ? Material.accent : Material.foreground
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                        }
                    }
                }
            }
        }
    }

    // 继承BaseDialog的动画

onAccepted: {
        if (taskTitle.trim() !== "") {
            taskController.addTask(taskTitle, taskDescription, selectedQuadrant)
        }
    }
    
    onOpened: {
        // 重置表单
        titleField.text = ""
        descriptionField.text = ""
        selectedQuadrant = 4
        titleField.forceActiveFocus()
    }
}