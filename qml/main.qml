import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Shapes 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 800
    title: qsTr("四象限任务管理")
    color: "#f5f7fa"
    
    // 定义应用主题颜色
    readonly property color primaryColor: "#4361ee"
    readonly property color secondaryColor: "#3f37c9"
    readonly property color accentColor: "#4cc9f0"
    readonly property color successColor: "#4cc9f0"
    readonly property color warningColor: "#f72585"
    readonly property color dangerColor: "#ef233c"
    readonly property color lightColor: "#f8f9fa"
    readonly property color darkColor: "#1a1a2e"
    readonly property color textColor: "#2b2d42"
    readonly property color textLightColor: "#8d99ae"
    
    // 顶部导航栏
    header: Rectangle {
        id: headerBar
        height: 64
        color: "white"
        border.width: 0
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            // 应用Logo和标题
            RowLayout {
                spacing: 8
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: root.primaryColor
                    
                    Text {
                        anchors.centerIn: parent
                        text: "📝"
                        font.pixelSize: 16
                    }
                }
                
                Text {
                    text: qsTr("四象限任务管理")
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: root.darkColor
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // 视图切换按钮
            RowLayout {
                spacing: 4
                
                TabButton {
                    id: activeTasksTab
                    text: qsTr("活动任务")
                    font.pixelSize: 14
                    checked: true
                    onCheckedChanged: {
                        if (checked) {
                            mainStackView.replace(activeTasksPage)
                        }
                    }
                    
                    contentItem: Text {
                        text: activeTasksTab.text
                        font.pixelSize: 14
                        font.weight: activeTasksTab.checked ? Font.Medium : Font.Normal
                        color: activeTasksTab.checked ? root.primaryColor : root.textLightColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    background: Item {
                        Rectangle {
                            visible: activeTasksTab.checked
                            width: parent.width
                            height: 2
                            color: root.primaryColor
                            anchors.bottom: parent.bottom
                        }
                    }
                }
                
                TabButton {
                    id: completedTasksTab
                    text: qsTr("已完成任务")
                    font.pixelSize: 14
                    onCheckedChanged: {
                        if (checked) {
                            mainStackView.replace(completedTasksPage)
                        }
                    }
                    
                    contentItem: Text {
                        text: completedTasksTab.text
                        font.pixelSize: 14
                        font.weight: completedTasksTab.checked ? Font.Medium : Font.Normal
                        color: completedTasksTab.checked ? root.primaryColor : root.textLightColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    background: Item {
                        Rectangle {
                            visible: completedTasksTab.checked
                            width: parent.width
                            height: 2
                            color: root.primaryColor
                            anchors.bottom: parent.bottom
                        }
                    }
                }
            }
            
            // 添加任务按钮
            Button {
                id: addTaskButton
                text: qsTr("添加任务")
                font.pixelSize: 14
                font.weight: Font.Medium
                
                contentItem: RowLayout {
                    spacing: 6
                    
                    Text {
                        text: "+"
                        font.pixelSize: 16
                        color: "white"
                    }
                    
                    Text {
                        text: qsTr("添加任务")
                        font.pixelSize: 14
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    implicitHeight: 36
                    implicitWidth: 100
                    radius: 18
                    color: root.primaryColor
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: "white"
                        opacity: addTaskButton.down ? 0.2 : 0
                    }
                }
                
                onClicked: {
                    addTaskDialog.open()
                }
            }
        }
    }
    
    // 主内容区域
    StackView {
        id: mainStackView
        anchors.fill: parent
        initialItem: activeTasksPage
        
        // 页面过渡动画
        replaceEnter: Transition {
            ParallelAnimation {
                PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
                PropertyAnimation { property: "x"; from: 20; to: 0; duration: 300 }
            }
        }
        replaceExit: Transition {
            ParallelAnimation {
                PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
                PropertyAnimation { property: "x"; from: 0; to: -20; duration: 200 }
            }
        }
    }
    
    // 活动任务页面
    Component {
        id: activeTasksPage
        
        Rectangle {
            color: "#f5f7fa"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 24
                
                // 页面标题
                Text {
                    text: qsTr("四象限任务管理")
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    color: root.darkColor
                }
                
                // 四象限容器
                GridLayout {
                    rows: 2
                    columns: 2
                    rowSpacing: 20
                    columnSpacing: 20
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    // 第一象限 - 重要紧急
                    QuadrantPanel {
                        quadrantNumber: 1
                        quadrantTitle: qsTr("重要且紧急")
                        quadrantColor: root.dangerColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    // 第二象限 - 重要不紧急
                    QuadrantPanel {
                        quadrantNumber: 2
                        quadrantTitle: qsTr("重要不紧急")
                        quadrantColor: root.warningColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    // 第三象限 - 不重要紧急
                    QuadrantPanel {
                        quadrantNumber: 3
                        quadrantTitle: qsTr("不重要但紧急")
                        quadrantColor: root.accentColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    // 第四象限 - 不重要不紧急
                    QuadrantPanel {
                        quadrantNumber: 4
                        quadrantTitle: qsTr("不重要不紧急")
                        quadrantColor: root.textLightColor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
    
    // 已完成任务页面
    Component {
        id: completedTasksPage
        
        Rectangle {
            color: "#f5f7fa"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 24
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: qsTr("已完成任务")
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        color: root.darkColor
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: qsTr("清空")
                        font.pixelSize: 14
                        
                        contentItem: Text {
                            text: qsTr("清空")
                            font.pixelSize: 14
                            color: root.dangerColor
                        }
                        
                        background: Rectangle {
                            color: "transparent"
                            border.width: 1
                            border.color: root.dangerColor
                            radius: 16
                        }
                    }
                }
                
                // 已完成任务列表
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 12
                    border.width: 1
                    border.color: "#e9ecef"
                    
                    ListView {
                        id: completedTasksList
                        anchors.fill: parent
                        // 添加clip属性确保内容不会溢出
                        clip: true
                        model: taskController.getCompletedTasks()
                        delegate: CompletedTaskItem {
                            // 使用ListView.view.width而不是直接引用completedTasksList.width
                            width: ListView.view.width
                        }
                        spacing: 1
                        
                        ScrollBar.vertical: ScrollBar {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.topMargin: 6
                            anchors.bottomMargin: 6
                            contentItem: Rectangle {
                                implicitWidth: 4
                                radius: 2
                                color: "#e9ecef"
                                
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: 2
                                    color: root.primaryColor
                                }
                            }
                        }
                    }
                }
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
    
    // 初始化任务列表
    Component.onCompleted: {
        taskController.refreshTasks()
    }
}