import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
// Material样式通过BaseDialog和InputField组件继承，无需直接导入

BaseDialog {
    id: editTaskDialog
    title: "编辑任务"
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: 480
    height: 400
    

    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // 任务标题输入框
        InputField {
            id: titleField
            label: "任务标题"
            text: taskTitle
            placeholderText: "任务标题"
            Layout.fillWidth: true
            onTextEdited: taskTitle = text
        }

        // 任务描述输入框
        InputField {
            id: descriptionField
            label: "任务描述"
            text: taskDescription
            placeholderText: "任务描述"
            isTextArea: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onTextEdited: taskDescription = text
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