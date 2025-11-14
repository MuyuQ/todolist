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
                            // 页面加载完成后延迟刷新已完成任务数据
                            Qt.callLater(function() {
                                // 延迟检查并更新已完成任务列表
                                var checkAndRefresh = function() {
                                    // 尝试获取当前页面的已完成任务列表
                                    var currentItem = mainStackView.currentItem
                                    if (currentItem && currentItem.children && currentItem.children.length > 0) {
                                        // 查找已完成任务列表
                                        for (var i = 0; i < currentItem.children.length; i++) {
                                            var child = currentItem.children[i]
                                            if (child.objectName === "completedTasksList") {
                                                child.model = taskController.getCompletedTasks()
                                                break
                                            }
                                        }
                                    }
                                }
                                checkAndRefresh()
                            })
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
            
            // 已完成任务列表数据源
            property var completedTasksModel: taskController ? taskController.getCompletedTasks() : []
            
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
                        
                        // 清空按钮点击事件
                        onClicked: {
                            consoleLogger.log("清空按钮被点击")
                            // 直接执行清空操作
                            taskController.clearCompletedTasks()
                            
                            // 立即更新模型引用
                            refreshCompletedTasksList()
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
                        objectName: "completedTasksList"
                        anchors.fill: parent
                        // 添加clip属性确保内容不会溢出
                        clip: true
                        model: taskController.getCompletedTasks()
                        delegate: CompletedTaskItem {
                            // 使用ListView.view.width而不是直接引用completedTasksList.width
                            width: ListView.view.width
                            
                            // 绑定model数据属性
                            taskId: modelData.taskId
                            taskTitle: modelData.taskTitle
                            taskDescription: modelData.taskDescription
                            taskQuadrant: modelData.taskQuadrant
                            createdAt: modelData.createdAt
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
        
        // 监听任务更新信号，自动刷新已完成任务页面
        taskController.taskUpdated.connect(refreshCompletedTasksList)
        
        // 定时器，用于强制刷新已完成任务列表
        refreshTimer.start()
    }
    
    // 定时器用于强制刷新
    Timer {
        id: refreshTimer
        interval: 100
        repeat: true
        running: false
        property int counter: 0
        
        onTriggered: {
            if (completedTasksTab.checked) {
                refreshCompletedTasksList()
            }
        }
    }
    
    // 专门处理已完成任务列表刷新的函数
    function refreshCompletedTasksList() {
        consoleLogger.log("=== 任务更新信号被触发 ===")
        
        // 检查taskController是否可用
        if (!taskController) {
            consoleLogger.log("taskController不可用，跳过刷新")
            return
        }
        
        // 如果当前在已完成任务页面，强制刷新已完成任务列表
        if (completedTasksTab.checked && mainStackView.currentItem) {
            consoleLogger.log("当前在已完成任务页面，开始刷新列表")
            
            // 查找已完成任务列表并强制刷新model
            var currentItem = mainStackView.currentItem
            if (currentItem && currentItem.children && currentItem.children.length > 0) {
                for (var i = 0; i < currentItem.children.length; i++) {
                    var child = currentItem.children[i]
                    if (child.objectName === "completedTasksList") {
                        consoleLogger.log("找到已完成任务列表，准备刷新")
                        
                        // 获取新的数据并立即刷新
                        if (taskController) {
                            var newModel = taskController.getCompletedTasks()
                            consoleLogger.log("获取到新数据，任务数量: " + newModel.length)
                            
                            // 强制更新ListView的model属性
                            child.model = newModel
                            child.forceLayout()
                            child.update()
                            
                            // 尝试重新设置model属性
                            Qt.callLater(function() {
                                if (child && child.objectName === "completedTasksList" && taskController) {
                                    var newModelAgain = taskController.getCompletedTasks()
                                    consoleLogger.log("延迟刷新，任务数量: " + newModelAgain.length)
                                    child.model = newModelAgain
                                    child.forceLayout()
                                    child.update()
                                }
                            })
                        }
                        
                        consoleLogger.log("已完成任务列表刷新完成")
                        break
                    }
                }
            } else {
                consoleLogger.log("无法找到已完成任务页面的子组件")
            }
        } else {
            consoleLogger.log("不在已完成任务页面，不刷新列表")
        }
    }
}