import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: editTaskDialog
    
    title: qsTr("编辑任务")
    width: 500
    height: 400
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    property int taskId: -1
    property alias taskTitle: titleInput.text
    property alias taskDescription: descriptionInput.text
    property int selectedQuadrant: 4
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20
        
        // 任务标题输入
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            
            Text {
                text: qsTr("任务标题")
                font.pixelSize: 14
                font.weight: Font.Medium
                color: "#2b2d42"
            }
            
            Rectangle {
                height: 48
                Layout.fillWidth: true
                color: "white"
                border.width: 1
                border.color: "#e9ecef"
                radius: 8
                
                TextField {
                    id: titleInput
                    anchors.fill: parent
                    anchors.margins: 12
                    placeholderText: qsTr("请输入任务标题")
                    font.pixelSize: 16
                    color: "#2b2d42"
                    selectionColor: "#4361ee"
                    selectedTextColor: "white"
                    
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }
        
        // 任务描述输入
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Text {
                text: qsTr("任务描述")
                font.pixelSize: 14
                font.weight: Font.Medium
                color: "#2b2d42"
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.width: 1
                border.color: "#e9ecef"
                radius: 8
                
                TextArea {
                    id: descriptionInput
                    anchors.fill: parent
                    anchors.margins: 12
                    placeholderText: qsTr("请输入任务描述（可选）")
                    font.pixelSize: 16
                    color: "#2b2d42"
                    selectionColor: "#4361ee"
                    selectedTextColor: "white"
                    wrapMode: TextEdit.Wrap
                    
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }
        
        // 象限选择
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            
            Text {
                text: qsTr("任务象限")
                font.pixelSize: 14
                font.weight: Font.Medium
                color: "#2b2d42"
            }
            
            GridLayout {
                rows: 2
                columns: 2
                rowSpacing: 8
                columnSpacing: 8
                Layout.fillWidth: true
                
                Loader {
                    sourceComponent: quadrantButtonComponent
                    property int quadrantNumber: 1
                    property string quadrantTitle: qsTr("重要且紧急")
                    property color quadrantColor: "#ef233c"
                    property bool isSelected: selectedQuadrant === 1
                    onLoaded: item.clicked.connect(function() { selectedQuadrant = 1 })
                }
                
                Loader {
                    sourceComponent: quadrantButtonComponent
                    property int quadrantNumber: 2
                    property string quadrantTitle: qsTr("重要不紧急")
                    property color quadrantColor: "#f72585"
                    property bool isSelected: selectedQuadrant === 2
                    onLoaded: item.clicked.connect(function() { selectedQuadrant = 2 })
                }
                
                Loader {
                    sourceComponent: quadrantButtonComponent
                    property int quadrantNumber: 3
                    property string quadrantTitle: qsTr("不重要但紧急")
                    property color quadrantColor: "#4cc9f0"
                    property bool isSelected: selectedQuadrant === 3
                    onLoaded: item.clicked.connect(function() { selectedQuadrant = 3 })
                }
                
                Loader {
                    sourceComponent: quadrantButtonComponent
                    property int quadrantNumber: 4
                    property string quadrantTitle: qsTr("不重要不紧急")
                    property color quadrantColor: "#8d99ae"
                    property bool isSelected: selectedQuadrant === 4
                    onLoaded: item.clicked.connect(function() { selectedQuadrant = 4 })
                }
            }
        }
    }
    
    // 按钮区域
    footer: RowLayout {
        width: parent.width
        anchors.margins: 16
        spacing: 12
        
        Button {
            text: qsTr("删除")
            font.pixelSize: 14
            font.weight: Font.Medium
            
            contentItem: Text {
                text: qsTr("删除")
                font.pixelSize: 14
                color: "#ef233c"
            }
            
            background: Rectangle {
                color: "#fff0f0"
                radius: 8
                border.width: 1
                border.color: "#ef233c"
            }
            
            onClicked: {
                if (taskId !== -1) {
                    // 删除任务功能实现
                    taskController.deleteTask(taskId)
                    editTaskDialog.close()
                }
            }
        }
        
        Item { Layout.fillWidth: true }
        
        Button {
            text: qsTr("取消")
            font.pixelSize: 14
            font.weight: Font.Medium
            
            contentItem: Text {
                text: qsTr("取消")
                font.pixelSize: 14
                color: "#8d99ae"
            }
            
            background: Rectangle {
                color: "#f8f9fa"
                radius: 8
            }
            
            onClicked: {
                editTaskDialog.close()
            }
        }
        
        Button {
            text: qsTr("保存")
            font.pixelSize: 14
            font.weight: Font.Medium
            
            contentItem: Text {
                text: qsTr("保存")
                font.pixelSize: 14
                color: "white"
            }
            
            background: Rectangle {
                color: "#4361ee"
                radius: 8
            }
            
            onClicked: {
                if (titleInput.text.trim() && taskId !== -1) {
                    taskController.updateTask(taskId, titleInput.text.trim(), descriptionInput.text.trim())
                    taskController.moveTaskToQuadrant(taskId, selectedQuadrant)
                    editTaskDialog.close()
                }
            }
        }
    }
    
    // 象限选择按钮组件
    Component {
        id: quadrantButtonComponent
        
        Rectangle {
            property int quadrantNumber: 1
            property string quadrantTitle: "象限"
            property color quadrantColor: "#4361ee"
            property bool isSelected: false
            signal clicked
            
            height: 60
            Layout.fillWidth: true
            color: isSelected ? quadrantColor : "white"
            border.width: 1
            border.color: isSelected ? quadrantColor : "#e9ecef"
            radius: 8
            
            MouseArea {
                anchors.fill: parent
                onClicked: parent.clicked()
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4
                
                Text {
                    text: "Q" + quadrantNumber
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: isSelected ? "white" : quadrantColor
                }
                
                Text {
                    text: quadrantTitle
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: isSelected ? "white" : "#2b2d42"
                }
            }
        }
    }
    
    // 已移除QuadrantButton函数，改用Loader组件直接加载
    
    // 打开对话框并设置任务数据
    function open(id, title, description, quadrant) {
        taskId = id
        titleInput.text = title
        descriptionInput.text = description || ""
        selectedQuadrant = quadrant || 4
        editTaskDialog.open()
    }
    
    onOpened: {
        titleInput.forceActiveFocus()
    }
}