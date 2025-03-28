import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Dialog {
    id: editTaskDialog
    modal: true
    title: "编辑任务"
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
            text: editTaskDialog.title
            font.pixelSize: 20
            font.weight: Font.Medium
            color: Material.foreground
        }
    }
    
    // 对话框按钮样式
    footer: DialogButtonBox {
        standardButtons: editTaskDialog.standardButtons
        padding: 16
        alignment: Qt.AlignRight
        Material.background: "transparent"
        Material.elevation: 0
        
        onAccepted: editTaskDialog.accept()
        onRejected: editTaskDialog.reject()
    }

    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // 任务标题输入框
        TextField {
            id: titleField
            text: taskTitle
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
                text: taskDescription
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
    }

    onAccepted: {
        if (taskTitle.trim() !== "") {
            taskController.updateTask(taskId, taskTitle, taskDescription)
        }
    }
    
    onOpened: {
        // 聚焦到标题输入框
        titleField.forceActiveFocus()
        titleField.selectAll()
    }
}