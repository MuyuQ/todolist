import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 800
    title: qsTr("时光四象限")
    color: "#fafafa"
    
    // Material主题设置
    Material.theme: Material.Light
    Material.accent: Material.Blue
    Material.primary: Material.Indigo
    
    // 常量定义
    QtObject {
        id: constants
        property var quadrantColors: ["#ef5350", "#66bb6a", "#42a5f5", "#ab47bc"]
        property var quadrantTitles: ["重要且紧急", "重要不紧急", "不重要但紧急", "不重要不紧急"]
        property color primaryColor: Material.primary
        property color secondaryColor: Material.accent
    }
    
    // 字体
    FontLoader {
        id: elegantFont
        source: "https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap"
    }
    
    // 获取象限颜色函数
    function getQuadrantColor(quadrant) {
        return quadrant >= 1 && quadrant <= 4 ? constants.quadrantColors[quadrant - 1] : "#e0e0e0";
    }
    
    // 获取象限标题函数
    function getQuadrantTitle(quadrant) {
        return quadrant >= 1 && quadrant <= 4 ? constants.quadrantTitles[quadrant - 1] : "未分类";
    }
    
    // 顶部应用栏
    header: ToolBar {
        id: mainToolbar
        height: 64
        Material.elevation: 4
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            
            Label {
                text: qsTr("时光四象限")
                font.pixelSize: 22
                font.weight: Font.Medium
                color: "white"
            }
            
            Item { Layout.fillWidth: true }
            
            TabBar {
                id: viewTabBar
                Material.background: "transparent"
                Material.foreground: "white"
                
                TabButton {
                    id: activeTasks
                    text: qsTr("活动任务")
                    font.pixelSize: 14
                    width: implicitWidth + 20
                    onClicked: mainStackView.replace(activeTasksPage)
                }
                
                TabButton {
                    id: completedTasks
                    text: qsTr("已完成任务")
                    font.pixelSize: 14
                    width: implicitWidth + 20
                    onClicked: mainStackView.replace(completedTasksPage)
                }
            }
            
            Button {
                text: qsTr("添加任务")
                highlighted: true
                Material.elevation: 1
                onClicked: addTaskDialog.open()
                
                contentItem: RowLayout {
                    spacing: 8
                    
                    Text {
                        text: "＋"
                        font.pixelSize: 16
                        color: "white"
                    }
                    
                    Text {
                        text: qsTr("添加任务")
                        font.pixelSize: 14
                        color: "white"
                    }
                }
            }
        }
    }
    
    // 主内容区域
    StackView {
        id: mainStackView
        anchors.fill: parent
        anchors.margins: 16
        initialItem: activeTasksPage
        
        // 过渡动画设置
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.InCubic
            }
        }
    }
    
    // 活动任务页面组件
    Component {
        id: activeTasksPage
        
        Pane {
            Material.elevation: 0
            Material.background: "transparent"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 16
                
                // 页面标题
                Label {
                    text: qsTr("四象限任务管理")
                    font.pixelSize: 24
                    font.weight: Font.Medium
                    color: Material.foreground
                }
                
                // 四象限区域
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    rows: 2
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    Repeater {
                        model: 4
                        
                        QuadrantPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            quadrantNumber: index + 1
                            quadrantTitle: getQuadrantTitle(index + 1)
                            quadrantColor: getQuadrantColor(index + 1)
                            
                            // 添加出现动画
                            NumberAnimation on opacity {
                                from: 0
                                to: 1
                                duration: 300 + index * 100
                                easing.type: Easing.OutCubic
                                running: true
                            }
                            
                            NumberAnimation on scale {
                                from: 0.95
                                to: 1.0
                                duration: 300 + index * 100
                                easing.type: Easing.OutCubic
                                running: true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 已完成任务页面组件
    Component {
        id: completedTasksPage
        
        CompletedTaskList {
            anchors.fill: parent
            
            // 添加出现动画
            NumberAnimation on opacity {
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
                running: true
            }
        }
    }
    
    // 添加任务对话框
    AddTaskDialog {
        id: addTaskDialog
    }
    
    // 编辑任务对话框
    EditTaskDialog {
        id: editTaskDialog
    }
    
    // 初始化
    Component.onCompleted: {
        taskController.refreshTasks()
    }
}