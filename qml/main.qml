import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 800
    title: qsTr("时光四象限")
    color: "#fafafa" // 更柔和的背景色
    
    // 字体设置 - 使用系统字体
    // 字体对象
    FontLoader {
        id: elegantFont
        source: "Microsoft YaHei UI"
    }
    
    // 定义颜色 - 更柔和的色调
    readonly property color quadrant1Color: "#ffccd5" // 重要且紧急 - 柔和玫瑰色
    readonly property color quadrant2Color: "#c9e7cb" // 重要不紧急 - 柔和薄荷色
    readonly property color quadrant3Color: "#cce5ff" // 不重要但紧急 - 柔和天空蓝
    readonly property color quadrant4Color: "#e6d8f0" // 不重要不紧急 - 柔和薰衣草色
    
    // 获取象限颜色
    function getQuadrantColor(quadrant) {
        switch(quadrant) {
            case 1: return quadrant1Color;
            case 2: return quadrant2Color;
            case 3: return quadrant3Color;
            case 4: return quadrant4Color;
            default: return "#e0e0e0";
        }
    }
    
    // 获取象限标题
    function getQuadrantTitle(quadrant) {
        switch(quadrant) {
            case 1: return "重要且紧急";
            case 2: return "重要不紧急";
            case 3: return "不重要但紧急";
            case 4: return "不重要不紧急";
            default: return "未分类";
        }
    }
    
    // 顶部工具栏 - WinUI3风格
    header: ToolBar {
        height: 60
        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
        }
        
        // 工具栏阴影
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 3
            radius: 8.0
            samples: 17
            color: "#40000000"
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            
            Label {
                text: qsTr("时光四象限")
                font.family: elegantFont.name
                font.pixelSize: 24
                font.weight: Font.Light
                color: "white"
                
                // 添加微妙的文字阴影
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 1
                    verticalOffset: 1
                    radius: 3.0
                    samples: 17
                    color: "#80000000"
                }
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: qsTr("添加任务")
                onClicked: addTaskDialog.open()
                background: Rectangle {
                    color: "#ffffff"
                    radius: 20
                    opacity: parent.hovered ? 0.95 : 0.9
                    
                    // 微妙的悬停动画
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }
                contentItem: Text {
                    text: parent.text
                    font.family: elegantFont.name
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#6a11cb"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                padding: 12
                // 添加点击动画
                scale: pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }
    }
    
    // 主内容区域 - WinUI3风格
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // 标签页 - 现代化风格
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            height: 52
            position: TabBar.Header
            background: Rectangle {
                color: "transparent"
                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    color: "#e0e0e0"
                }
            }
            
            // 活动任务标签
            TabButton {
                text: "活动任务"
                font.family: elegantFont.name
                font.pixelSize: 16
                font.weight: Font.Medium
                height: parent.height
                width: implicitWidth + 40
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.checked ? "#6a11cb" : "#777777"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                background: Rectangle {
                    color: "transparent"
                    Rectangle {
                        width: parent.width
                        height: 3
                        anchors.bottom: parent.bottom
                        color: parent.parent.checked ? "#6a11cb" : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
            
            // 已完成任务标签
            TabButton {
                text: "已完成任务"
                font.family: elegantFont.name
                font.pixelSize: 16
                font.weight: Font.Medium
                height: parent.height
                width: implicitWidth + 40
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.checked ? "#6a11cb" : "#777777"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                background: Rectangle {
                    color: "transparent"
                    Rectangle {
                        width: parent.width
                        height: 3
                        anchors.bottom: parent.bottom
                        color: parent.parent.checked ? "#6a11cb" : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
        
        // 标签页内容
        StackLayout {
            currentIndex: tabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // 活动任务页面
            RowLayout {
                spacing: 16
                
                // 四象限网格
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.7
                    columns: 2
                    rows: 2
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // 四个象限
                    Repeater {
                        model: 4
                        
                        QuadrantPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            quadrantNumber: index + 1
                            quadrantTitle: getQuadrantTitle(index + 1)
                            quadrantColor: getQuadrantColor(index + 1)
                        }
                    }
                }
                
                // 任务列表
                TaskList {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.3
                }
            }
            
            // 已完成任务页面
            CompletedTaskList {
                Layout.fillWidth: true
                Layout.fillHeight: true
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