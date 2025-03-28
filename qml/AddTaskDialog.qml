import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Dialog {
    id: addTaskDialog
    modal: true
    title: "创建新任务"
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    width: 480
    height: 400
    padding: 24
    
    // Material设计风格
    Material.elevation: 24
    Material.background: "white"
    
    // 对话框标题样式
    header: Pane {
        width: parent.width
        padding: 24
        Material.elevation: 0
        Material.background: "transparent"
        
        Label {
            text: addTaskDialog.title
            font.pixelSize: 20
            font.weight: Font.Medium
            color: Material.foreground
        }
    }
    
    // 对话框按钮样式
    footer: DialogButtonBox {
        standardButtons: addTaskDialog.standardButtons
        padding: 16
        alignment: Qt.AlignRight
        Material.background: "transparent"
        Material.elevation: 0
        
        onAccepted: addTaskDialog.accept()
        onRejected: addTaskDialog.reject()
    }

    property string taskTitle: ""
    property string taskDescription: ""
    property int selectedQuadrant: 4

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // 任务标题输入框
        TextField {
            id: titleField
            placeholderText: "任务标题"
            Layout.fillWidth: true
            font.pixelSize: 16
            selectByMouse: true
            onTextChanged: taskTitle = text
            
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 50
                color: "transparent"
                border.color: titleField.activeFocus ? Material.accent : "#e0e0e0"
                border.width: titleField.activeFocus ? 2 : 1
                radius: 4
            }
        }

        // 任务描述输入框
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            TextArea {
                id: descriptionField
                placeholderText: "任务描述"
                wrapMode: Text.WordWrap
                selectByMouse: true
                font.pixelSize: 14
                onTextChanged: taskDescription = text
                
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 100
                    color: "transparent"
                    border.color: descriptionField.activeFocus ? Material.accent : "#e0e0e0"
                    border.width: descriptionField.activeFocus ? 2 : 1
                    radius: 4
                }
            }
        }

        // 象限选择
        Label {
            text: "选择任务象限"
            font.pixelSize: 14
            color: Material.foreground
        }
        
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8
            
            Repeater {
                model: 4
                
                RadioButton {
                    text: getQuadrantTitle(index + 1)
                    checked: index + 1 === selectedQuadrant
                    onClicked: selectedQuadrant = index + 1
                    
                    contentItem: RowLayout {
                        spacing: 8
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: getQuadrantColor(index + 1)
                            border.width: 1
                            border.color: Qt.darker(getQuadrantColor(index + 1), 1.2)
                        }
                        
                        Text {
                            text: parent.parent.text
                            font.pixelSize: 14
                            color: Material.foreground
                        }
                    }
                }
            }
        }
    }

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