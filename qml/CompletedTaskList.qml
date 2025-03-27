import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    color: "#f8f8f8"
    radius: 12
    border.color: "transparent"
    border.width: 0
    
    // 现代化的阴影效果
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12.0
        samples: 17
        color: "#30000000"
    }
    
    // 已完成任务模型
    property var completedTasksModel: ListModel { id: completedTasksModel }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        
        // 标题区域 - WinUI3风格
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                
                Label {
                    text: "已完成任务"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: "#0078d4" // WinUI3主题色
                }
                
                Item { Layout.fillWidth: true }
                
                Label {
                    text: completedTasksList.count + " 个任务"
                    font.pixelSize: 14
                    color: "#666666"
                }
            }
        }
        
        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e0e0e0"
        }
        
        // 已完成任务列表
        ListView {
            id: completedTasksList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            
            model: completedTasksModel
            
            // 无任务时的提示
            Component {
                id: emptyState
                Item {
                    width: completedTasksList.width
                    height: 100
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "✓"
                            font.pixelSize: 32
                            color: "#0078d4"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "暂无已完成任务"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
            
            // 空列表状态
            Component {
                id: emptyStateDelegate
                Loader {
                    sourceComponent: emptyState
                    width: completedTasksList.width
                }
            }
            
            // 显示空状态
            Component.onCompleted: {
                if (count === 0) {
                    footerItem = emptyStateDelegate.createObject(completedTasksList)
                }
            }
            
            // 任务项代理
            delegate: Rectangle {
                width: completedTasksList.width
                height: 60
                radius: 4
                color: "white"
                border.color: "#e6e6e6"
                border.width: 1
                
                // 微妙的悬停效果
                states: State {
                    name: "hovered"
                    when: mouseArea.containsMouse
                    PropertyChanges { target: parent; color: "#f9f9f9" }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    // 点击恢复任务
                    onClicked: {
                        taskController.setTaskCompleted(model.id, false)
                    }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    // 完成标记
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: "#e6f7ff"
                        border.color: "#0078d4"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font.pixelSize: 14
                            color: "#0078d4"
                        }
                    }
                    
                    // 任务信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Label {
                            text: model.title
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#333333"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Label {
                            text: model.description || ""
                            font.pixelSize: 12
                            color: "#666666"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: model.description && model.description.length > 0
                        }
                    }
                    
                    // 象限标记
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 4
                        color: getQuadrantColor(model.quadrant)
                        
                        Text {
                            anchors.centerIn: parent
                            text: model.quadrant
                            font.pixelSize: 12
                            color: Qt.darker(getQuadrantColor(model.quadrant), 2.0)
                        }
                        
                        // 获取象限颜色
                        function getQuadrantColor(quadrant) {
                            switch(quadrant) {
                                case 1: return "#ffcdd2"; // 重要且紧急 - 浅红色
                                case 2: return "#c8e6c9"; // 重要不紧急 - 浅绿色
                                case 3: return "#bbdefb"; // 不重要但紧急 - 浅蓝色
                                case 4: return "#e1bee7"; // 不重要不紧急 - 浅紫色
                                default: return "#e0e0e0";
                            }
                        }
                    }
                }
            }
            
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
                
                // WinUI3风格滚动条
                contentItem: Rectangle {
                    implicitWidth: 6
                    implicitHeight: 100
                    radius: 3
                    color: parent.pressed ? "#666666" : "#999999"
                    opacity: parent.active ? 0.8 : 0.5
                }
            }
        }
    }
    
    // 加载已完成任务
    function loadCompletedTasks() {
        completedTasksModel.clear()
        var tasks = taskController.getCompletedTasks()
        
        if (tasks && tasks.length > 0) {
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i]
                completedTasksModel.append({
                    "id": task.id,
                    "title": task.title,
                    "description": task.description,
                    "quadrant": task.quadrant
                })
            }
            
            // 移除空状态
            if (completedTasksList.footerItem) {
                completedTasksList.footerItem.destroy()
                completedTasksList.footerItem = null
            }
        } else {
            // 显示空状态
            if (!completedTasksList.footerItem) {
                completedTasksList.footerItem = emptyStateDelegate.createObject(completedTasksList)
            }
        }
    }
    
    // 监听任务更新
    Connections {
        target: taskController
        function onTaskUpdated() {
            loadCompletedTasks()
        }
    }
    
    // 初始化
    Component.onCompleted: {
        loadCompletedTasks()
    }
}