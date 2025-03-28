import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    
    // 属性
    property int quadrantNumber: 1
    property string quadrantTitle: "未分类"
    property color quadrantColor: "#e0e0e0"
    
    // 现代化面板样式
    color: quadrantColor
    radius: 12
    border.color: "transparent"
    border.width: 0
    
    // 精致的阴影效果
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12.0
        samples: 17
        color: "#30000000"
    }
    
    // 布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // 面板标题
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: Qt.darker(quadrantColor, 1.05)
            radius: 4
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                
                Label {
                    text: quadrantTitle
                    font.pixelSize: 16
                    font.bold: true
                    color: Qt.darker(quadrantColor, 1.7)
                }
                
                Item { Layout.fillWidth: true }
                
                Label {
                    text: quadrantNumber
                    font.pixelSize: 14
                    color: Qt.darker(quadrantColor, 1.5)
                }
            }
        }
        
        // 任务列表容器
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            // 数据模型
            TaskListModel {
                id: taskListModel
                quadrantNumber: root.quadrantNumber
            }
            
            // 网格布局容器
            Item {
                width: parent.width
                height: parent.height
                
                // 计算网格位置的函数
                function calculateGridPosition(item) {
                    var gridX = Math.floor(item.x / 220)
                    var gridY = Math.floor(item.y / 90)
                    return { x: gridX, y: gridY }
                }
                
                // 计算新的任务索引
                function calculateNewIndex(item) {
                    var pos = calculateGridPosition(item)
                    var columns = Math.max(1, Math.floor(width / 220))
                    return pos.y * columns + pos.x
                }
                
                // 自动对齐到网格
                function snapToGrid(item) {
                    var gridX = Math.round(item.x / 220) * 220
                    var gridY = Math.round(item.y / 90) * 90
                    
                    // 确保不会超出容器边界
                    gridX = Math.max(0, Math.min(gridX, width - item.width))
                    gridY = Math.max(0, Math.min(gridY, height - item.height))
                    
                    // 设置新位置
                    item.x = gridX
                    item.y = gridY
                    
                    // 重新排列所有任务项
                    rearrangeTasks()
                }
                
                // 重新排列所有任务项
                function rearrangeTasks() {
                    // 获取所有任务项
                    var items = []
                    for (var i = 0; i < taskRepeater.count; i++) {
                        var item = taskRepeater.itemAt(i)
                        if (item !== null) {
                            items.push(item)
                        }
                    }
                    
                    // 按照order_index排序
                    items.sort(function(a, b) {
                        return a.taskId - b.taskId
                    })
                    
                    // 排列任务项
                    var columns = Math.max(1, Math.floor(width / 220))
                    var spacing = 10 // 设置间距
                    
                    for (var j = 0; j < items.length; j++) {
                        var row = Math.floor(j / columns)
                        var col = j % columns
                        
                        // 设置新位置，添加动画效果会在TaskItem中自动应用
                        // 不需要在这里动态添加Behavior
                        
                        // 设置新位置，考虑间距
                        items[j].x = col * (220 + spacing)
                        items[j].y = row * (90 + spacing)
                    }
                }
                
                Repeater {
                    id: taskRepeater
                    model: taskListModel.model
                    
                    TaskItem {
                        id: taskItem
                        width: 210
                        x: (model.order_index % Math.max(1, Math.floor(parent.width / 220))) * 220
                        y: Math.floor(model.order_index / Math.max(1, Math.floor(parent.width / 220))) * 90
                        taskId: model.id || -1
                        taskTitle: model.title || ""
                        taskDescription: model.description || ""
                        taskQuadrant: model.quadrant || 4
                        
                        // 拖拽完成后重新排序
                        onDragFinished: {
                            // 自动对齐到网格
                            parent.snapToGrid(taskItem)
                            // 计算新的任务索引
                            var newIndex = parent.calculateNewIndex(taskItem)
                            // 排列任务项顺序
                            taskController.updateTaskOrder(taskId, newIndex)
                        }
                    }
                }
            }
        }
    }
}