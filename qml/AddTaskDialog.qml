import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Dialog {
    id: addTaskDialog
    modal: true
    title: "创建新任务"
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

    property string taskTitle: ""
    property string taskDescription: ""
    property int selectedQuadrant: 4

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        TextField {
            id: titleField
            placeholderText: "任务标题"
            Layout.fillWidth: true
            onTextChanged: taskTitle = text
        }

        TextArea {
            id: descriptionField
            placeholderText: "任务描述"
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
            onTextChanged: taskDescription = text
        }

        ComboBox {
            id: quadrantComboBox
            Layout.fillWidth: true
            model: ListModel {
                ListElement { text: "重要且紧急"; quadrant: 1 }
                ListElement { text: "重要不紧急"; quadrant: 2 }
                ListElement { text: "不重要但紧急"; quadrant: 3 }
                ListElement { text: "不重要不紧急"; quadrant: 4 }
            }
            textRole: "text"
            currentIndex: 3
            onCurrentIndexChanged: selectedQuadrant = model.get(currentIndex).quadrant

            delegate: ItemDelegate {
                width: quadrantComboBox.width
                contentItem: Text {
                    text: model.text
                    color: "#333333"
                    font: quadrantComboBox.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: {
                        switch(model.quadrant) {
                            case 1: return "#ffcdd2";
                            case 2: return "#c8e6c9";
                            case 3: return "#bbdefb";
                            case 4: return "#e1bee7";
                            default: return "#e0e0e0";
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
}