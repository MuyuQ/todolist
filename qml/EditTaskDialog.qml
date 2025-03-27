import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: editTaskDialog
    modal: true
    title: "编辑任务"
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    width: 450
    height: 380
    
    // 现代化的对话框样式
    background: Rectangle {
        color: "white"
        radius: 12
        
        // 添加阴影效果
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12.0
            samples: 17
            color: "#40000000"
        }
    }

    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        TextField {
            id: titleField
            text: taskTitle
            placeholderText: "任务标题"
            Layout.fillWidth: true
            onTextChanged: taskTitle = text
        }

        TextArea {
            id: descriptionField
            text: taskDescription
            placeholderText: "任务描述"
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
            onTextChanged: taskDescription = text
        }
    }

    onAccepted: {
        if (taskTitle.trim() !== "") {
            taskController.updateTask(taskId, taskTitle, taskDescription)
        }
    }
}