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
    
    // 设置z轴层级，确保低于拖动中的任务项
    z: 1
    
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
                    var newIndex = pos.y * columns + pos.x
                    
                    // 确保索引有效
                    if (newIndex < 0) newIndex = 0;
                    
                    // 返回计算出的索引
                    return newIndex;
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
                    
                    // 重新排列所有任务项 - 延迟执行以确保数据库更新完成
                    Qt.callLater(rearrangeTasks)
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
                        // 使用模型中的order_index进行排序
                        var indexA = -1;
                        var indexB = -1;
                        
                        // 查找对应的模型索引
                        for (var i = 0; i < taskListModel.model.count; i++) {
                            var modelItem = taskListModel.model.get(i);
                            if (modelItem.id === a.taskId) indexA = modelItem.order_index;
                            if (modelItem.id === b.taskId) indexB = modelItem.order_index;
                        }
                        
                        // 如果找不到索引，则使用taskId作为备选排序依据
                        if (indexA === -1 || indexB === -1) {
                            return a.taskId - b.taskId;
                        }
                        
                        return indexA - indexB;
                    })
                    
                    // 计算最佳布局参数
                    var taskWidth = 210
                    var taskHeight = 80
                    var horizontalSpacing = 20 // 水平间距增加
                    var verticalSpacing = 15   // 垂直间距增加
                    
                    // 计算每行可容纳的任务数量
                    var effectiveWidth = width - horizontalSpacing // 减去初始边距
                    var columns = Math.max(1, Math.floor(effectiveWidth / (taskWidth + horizontalSpacing)))
                    
                    // 创建占位网格，用于检测位置冲突
                    var grid = {}
                    
                    // 为每个任务项分配位置
                    for (var j = 0; j < items.length; j++) {
                        // 初始位置基于索引
                        var initialRow = Math.floor(j / columns)
                        var initialCol = j % columns
                        
                        // 查找可用位置（避免重叠）
                        var row = initialRow
                        var col = initialCol
                        var posKey = row + "-" + col
                        
                        // 如果位置已被占用，尝试找到最近的可用位置
                        while (grid[posKey]) {
                            // 尝试同一行的下一列
                            col++
                            if (col >= columns) {
                                // 如果超出列数，移到下一行第一列
                                col = 0
                                row++
                            }
                            posKey = row + "-" + col
                        }
                        
                        // 标记此位置为已占用
                        grid[posKey] = true
                        
                        // 计算实际坐标
                        var xPos = col * (taskWidth + horizontalSpacing) + horizontalSpacing/2
                        var yPos = row * (taskHeight + verticalSpacing) + verticalSpacing/2
                        
                        // 设置任务项位置
                        items[j].x = xPos
                        items[j].y = yPos
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
                            // 确保立即重新排列所有任务项
                            Qt.callLater(function() {
                                parent.rearrangeTasks()
                            })
                        }
                    }
                }
            }
        }
    }
}