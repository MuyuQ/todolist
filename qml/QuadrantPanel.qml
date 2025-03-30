import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    
    property int quadrantNumber: 1
    property string quadrantTitle: "未分类"
    property color quadrantColor: "#e0e0e0"
    
    color: quadrantColor
    radius: 12
    border.width: 0
    z: 1
    
    // 阴影效果 - 优化版
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12.0
        samples: 12
        color: "#30000000"
    }
    
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
                
                // 计算网格参数
                readonly property int itemWidth: 210
                readonly property int gridSpacingX: 220
                readonly property int gridSpacingY: 90
                readonly property int gridMargin: 5
                readonly property int gridColumns: Math.max(1, Math.floor(width / gridSpacingX))
                
                function calculateNewIndex(item) {
                    return Math.floor(item.y / gridSpacingY) * gridColumns + Math.floor(item.x / gridSpacingX)
                }
                
                function snapToGrid(item) {
                    item.x = Math.max(0, Math.min(Math.round(item.x / gridSpacingX) * gridSpacingX, width - item.width))
                    item.y = Math.max(0, Math.min(Math.round(item.y / gridSpacingY) * gridSpacingY, height - item.height))
                    rearrangeTasks()
                }
                
                function rearrangeTasks() {
                    // 优化版 - 减少重复计算
                    var columns = gridColumns
                    var spacingX = gridSpacingX
                    var spacingY = gridSpacingY
                    var margin = gridMargin
                    
                    for (var i = 0; i < taskRepeater.count; i++) {
                        var item = taskRepeater.itemAt(i)
                        if (item) {
                            item.x = (i % columns) * spacingX + margin
                            item.y = Math.floor(i / columns) * spacingY + margin
                        }
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
                        
                        // 拖拽完成后重新排序 - 优化版
                        onDragFinished: {
                            // 自动对齐到网格
                            parent.snapToGrid(taskItem)
                            // 计算新的任务索引并更新
                            taskController.updateTaskOrder(taskId, parent.calculateNewIndex(taskItem))
                            // 重新排列所有任务项
                            Qt.callLater(parent.rearrangeTasks)
                        }
                    }
                }
            }
        }
    }
}