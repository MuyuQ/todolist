import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

// 导入Utils单例
import "." as QmlImports

Pane {
    id: root
    
    // Material设计风格
    Material.elevation: 1
    Material.background: "white"
    padding: 0
    
    // 已完成任务模型
    property var completedTasksModel: ListModel { id: completedTasksModel }
    
    // 更新已完成任务列表函数
    function updateCompletedTasks() {
        completedTasksModel.clear()
        var tasks = taskController.getCompletedTasks()
        var isEmpty = !tasks || tasks.length === 0
        
        // 只在状态变化时处理空任务列表状态
        if (isEmpty && !completedTasksList.footerItem) {
            completedTasksList.footerItem = emptyStateDelegate.createObject(completedTasksList)
        } else if (!isEmpty && completedTasksList.footerItem) {
            completedTasksList.footerItem.destroy()
            completedTasksList.footerItem = null
        }
        
        if (isEmpty) return
        
        // 添加任务到模型
        for (var i = 0; i < tasks.length; i++) {
            completedTasksModel.append(tasks[i])
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 标题区域
        Pane {
            Layout.fillWidth: true
            height: 56
            padding: 0
            Material.elevation: 0
            Material.background: Material.primary
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                
                Label {
                    text: "已完成任务"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "white"
                }
                
                Item { Layout.fillWidth: true }
                
                Label {
                    text: completedTasksList.count + " 个任务"
                    font.pixelSize: 14
                    color: "white"
                    opacity: 0.8
                }
            }
        }
        

        
        // 任务列表
        ListView {
            id: completedTasksList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 1
            model: completedTasksModel
            
            // 连接到任务控制器
            Component.onCompleted: {
                root.updateCompletedTasks()
            }
            
            Connections {
                target: taskController
                function onTaskUpdated() {
                    root.updateCompletedTasks()
                }
            }
            
            // 空状态项引用
            property var footerItem: null
            
            // 无任务时的提示
            Component {
                id: emptyState
                Item {
                    width: completedTasksList.width
                    height: 200
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 16
                        
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 64
                            height: 64
                            radius: 32
                            color: Material.accent
                            opacity: 0.1
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: 32
                                color: Material.accent
                            }
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "暂无已完成任务"
                            font.pixelSize: 16
                            color: Material.foreground
                            opacity: 0.6
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
            
            // 空状态已在updateCompletedTasks中处理
            
            // 任务项代理
            delegate: ItemDelegate {
                width: completedTasksList.width
                height: 72
                
                // 悬停效果
                highlighted: hovered
                
                // 点击恢复任务
                onClicked: {
                    taskController.setTaskCompleted(model.id, false)
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // 完成标记
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: Material.accent
                        opacity: 0.1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font.pixelSize: 14
                            color: Material.accent
                        }
                    }
                    
                    // 任务信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Label {
                            text: model.title
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: Material.foreground
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Label {
                            text: model.description || ""
                            font.pixelSize: 14
                            color: Material.foreground
                            opacity: 0.6
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: model.description && model.description.length > 0
                        }
                    }
                    
                    // 象限标记
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: QmlImports.Utils.getQuadrantColor(model.quadrant)
                        opacity: 0.7
                    }
                }
                
                // 分隔线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Material.dividerColor
                    anchors.bottom: parent.bottom
                }
            }
            
            // 滚动条
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}