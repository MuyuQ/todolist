import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Dialog {
    id: addTaskDialog
    
    title: qsTr("添加新任务")
    // 设置合适的宽度，让弹窗能够完全显示内容
    width: 400
    // 移除固定高度，使用自适应高度
    // height: 400
    // Dialog组件默认会在其父窗口中居中，移除自定义定位
    // x: (Screen.width - width) / 2
    // y: (Screen.height - height) / 2
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
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
                    placeholderTextColor: "#adb5bd" // 设置占位符文本颜色
                    font.pixelSize: 16
                    color: "#2b2d42"
                    // 重置为默认行为，避免自定义样式导致的渲染问题
                    // 移除可能干扰正常显示的设置
                    selectByMouse: true
                    focusPolicy: Qt.StrongFocus
                    // 使用默认背景样式
                }
            }
        }
        
        // 任务描述输入
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            // 移除Layout.fillHeight以避免占用过多空间
            
            Text {
                text: qsTr("任务描述")
                font.pixelSize: 14
                font.weight: Font.Medium
                color: "#2b2d42"
            }
            
            Rectangle {
                Layout.fillWidth: true
                // 设置固定的最小高度
                implicitHeight: 120
                color: "white"
                border.width: 1
                border.color: "#e9ecef"
                radius: 8
                
                TextArea {
                    id: descriptionInput
                    anchors.fill: parent
                    anchors.margins: 12
                    placeholderText: qsTr("请输入任务描述（可选）")
                    placeholderTextColor: "#adb5bd" // 设置占位符文本颜色
                    font.pixelSize: 16
                    color: "#2b2d42"
                    wrapMode: TextEdit.Wrap
                    // 重置为默认行为，避免自定义样式导致的渲染问题
                    selectByMouse: true
                    focusPolicy: Qt.StrongFocus
                    // 使用默认背景样式
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
                
                // 直接使用组件而非Loader，避免属性传递问题
                Rectangle {
                    height: 60
                    Layout.fillWidth: true
                    color: selectedQuadrant === 1 ? "#ef233c" : "white"
                    border.width: 1
                    border.color: selectedQuadrant === 1 ? "#ef233c" : "#e9ecef"
                    radius: 8
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedQuadrant = 1
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        
                        Text {
                            text: "Q1"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: selectedQuadrant === 1 ? "white" : "#ef233c"
                        }
                        
                        Text {
                            text: qsTr("重要且紧急")
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: selectedQuadrant === 1 ? "white" : "#2b2d42"
                        }
                    }
                }
                
                Rectangle {
                    height: 60
                    Layout.fillWidth: true
                    color: selectedQuadrant === 2 ? "#f72585" : "white"
                    border.width: 1
                    border.color: selectedQuadrant === 2 ? "#f72585" : "#e9ecef"
                    radius: 8
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedQuadrant = 2
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        
                        Text {
                            text: "Q2"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: selectedQuadrant === 2 ? "white" : "#f72585"
                        }
                        
                        Text {
                            text: qsTr("重要不紧急")
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: selectedQuadrant === 2 ? "white" : "#2b2d42"
                        }
                    }
                }
                
                Rectangle {
                    height: 60
                    Layout.fillWidth: true
                    color: selectedQuadrant === 3 ? "#4cc9f0" : "white"
                    border.width: 1
                    border.color: selectedQuadrant === 3 ? "#4cc9f0" : "#e9ecef"
                    radius: 8
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedQuadrant = 3
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        
                        Text {
                            text: "Q3"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: selectedQuadrant === 3 ? "white" : "#4cc9f0"
                        }
                        
                        Text {
                            text: qsTr("不重要但紧急")
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: selectedQuadrant === 3 ? "white" : "#2b2d42"
                        }
                    }
                }
                
                Rectangle {
                    height: 60
                    Layout.fillWidth: true
                    color: selectedQuadrant === 4 ? "#8d99ae" : "white"
                    border.width: 1
                    border.color: selectedQuadrant === 4 ? "#8d99ae" : "#e9ecef"
                    radius: 8
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedQuadrant = 4
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        
                        Text {
                            text: "Q4"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: selectedQuadrant === 4 ? "white" : "#8d99ae"
                        }
                        
                        Text {
                            text: qsTr("不重要不紧急")
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: selectedQuadrant === 4 ? "white" : "#2b2d42"
                        }
                    }
                }
            }
        }
    }
    
    // 按钮区域
    footer: RowLayout {
            width: parent.width
            anchors.margins: 16
            spacing: 12
        
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
                addTaskDialog.close()
            }
        }
        
        Button {
            text: qsTr("确定")
            font.pixelSize: 14
            font.weight: Font.Medium
            
            contentItem: Text {
                text: qsTr("确定")
                font.pixelSize: 14
                color: "white"
            }
            
            background: Rectangle {
                color: "#4361ee"
                radius: 8
            }
            
            onClicked: {
                if (titleInput.text.trim()) {
                    taskController.addTask(titleInput.text.trim(), descriptionInput.text.trim(), selectedQuadrant)
                    addTaskDialog.close()
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
    
    // 注册象限按钮组件
    function createQuadrantButton() {
        return quadrantButtonComponent.createObject(parent)
    }
    
    // 重置表单
    function resetForm() {
        titleInput.text = ""
        descriptionInput.text = ""
        selectedQuadrant = 4
    }
    
    onOpened: {
        resetForm()
        titleInput.forceActiveFocus()
    }
}