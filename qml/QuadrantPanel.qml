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
        spacing: 8
        
        // 面板标题和布局切换按钮
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
                
                // 布局切换按钮
                Button {
                    id: layoutToggleButton
                    width: 36
                    height: 36
                    checkable: true
                    checked: false // 默认为手动布局模式
                    
                    property bool isAutoLayout: checked
                    
                    // 切换布局模式时重新排列任务项
                    onIsAutoLayoutChanged: {
                        // 添加短暂延迟，确保视图已更新
                        layoutChangeTimer.start()
                    }
                    
                    Timer {
                        id: layoutChangeTimer
                        interval: 50
                        onTriggered: {
                            // 刷新任务列表并重新排列任务项
                            taskListModel.updateTasks()
                        }
                    }
                    
                    contentItem: Item {
                        anchors.fill: parent
                        
                        Text {
                            anchors.centerIn: parent
                            text: layoutToggleButton.isAutoLayout ? "网" : "格"
                            font.pixelSize: 18
                            font.bold: true
                            color: layoutToggleButton.isAutoLayout ? "#0078d4" : Qt.darker(quadrantColor, 1.7)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        // 模式指示点
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: layoutToggleButton.isAutoLayout ? "#0078d4" : "transparent"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: 3
                            anchors.bottomMargin: 3
                        }
                    }
                    
                    background: Rectangle {
                        radius: 6
                        color: layoutToggleButton.isAutoLayout ? 
                               Qt.lighter(quadrantColor, 1.1) : "transparent"
                        border.color: layoutToggleButton.isAutoLayout ? 
                                     "#0078d4" : Qt.darker(quadrantColor, 1.2)
                        border.width: layoutToggleButton.isAutoLayout ? 2 : 1
                        
                        // 添加过渡动画
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    
                    // 添加点击动画
                    scale: layoutToggleButton.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: layoutToggleButton.isAutoLayout ? "切换到手动布局" : "切换到自动布局"
                    ToolTip.delay: 500
                }
                
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
            
            // 根据布局模式选择不同视图
            Item {
                width: parent.width
                height: parent.height
                
                // 布局视图 - 自动布局模式
                GridView {
                    id: autoGridView
                    anchors.fill: parent
                    visible: layoutToggleButton.isAutoLayout
                    model: taskListModel.model
                    cellWidth: 220
                    cellHeight: 90
                    flow: GridView.FlowLeftToRight
                    clip: true
                    
                    // 布局平滑滚动效果
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 1500
                    maximumFlickVelocity: 2500
                    
                    // 确保网格项之间有足够间距
                    property int horizontalSpacing: 10
                    property int verticalSpacing: 10
                    
                    delegate: TaskItem {
                        width: 210
                        taskId: model.id || -1
                        taskTitle: model.title || ""
                        taskDescription: model.description || ""
                        taskQuadrant: model.quadrant || 4
                        
                        // 自动布局模式下的视觉效果
                        scale: 1.0
                        opacity: 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        
                        // 自动布局模式下禁止拖拽
                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                if (layoutToggleButton.isAutoLayout) {
                                    // 显示提示：自动布局模式下不能拖拽
                                    autoLayoutTooltip.visible = true
                                    autoLayoutTooltipTimer.restart()
                                    
                                    // 添加点击动画效果
                                    parent.scale = 0.95
                                    clickFeedbackTimer.restart()
                                }
                            }
                            
                            Timer {
                                id: clickFeedbackTimer
                                interval: 100
                                onTriggered: parent.parent.scale = 1.0
                            }
                        }
                    }
                }
                
                // 布局容器 - 手动布局模式
                Item {
                    id: manualLayoutContainer
                    anchors.fill: parent
                    visible: !layoutToggleButton.isAutoLayout
                    
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
                        var gridSize = 220
                        var gridX = Math.round(item.x / gridSize) * gridSize
                        var gridY = Math.round(item.y / gridSize) * gridSize
                        
                        // 确保不会超出容器边界
                        gridX = Math.max(0, Math.min(gridX, width - item.width))
                        gridY = Math.max(0, Math.min(gridY, height - item.height))
                        
                        // 设置新位置
                        item.x = gridX
                        item.y = gridY
                    }
                    
                    // 重新排列所有任务项
                    function rearrangeTasks() {
                        // 获取所有任务项
                        var items = []
                        for (var i = 0; i < taskRepeater.count; i++) {
                            items.push(taskRepeater.itemAt(i))
                        }
                        
                        // 按照order_index排序
                        items.sort(function(a, b) {
                            return a.taskId - b.taskId
                        })
                        
                        // 排列任务项
                        var columns = Math.max(1, Math.floor(width / 220))
                        for (var j = 0; j < items.length; j++) {
                            var row = Math.floor(j / columns)
                            var col = j % columns
                            items[j].x = col * 220
                            items[j].y = row * 90
                        }
                    }
                    
                    Repeater {
                        id: taskRepeater
                        model: taskListModel.model
                        
                        TaskItem {
                            id: taskItem
                            width: 210
                            x: (model.order_index % Math.max(1, Math.floor(manualLayoutContainer.width / 220))) * 220
                            y: Math.floor(model.order_index / Math.max(1, Math.floor(manualLayoutContainer.width / 220))) * 90
                            taskId: model.id || -1
                            taskTitle: model.title || ""
                            taskDescription: model.description || ""
                            taskQuadrant: model.quadrant || 4
                            
                            // 拖拽完成后重新排序
                            onDragFinished: {
                                // 自动对齐到网格
                                manualLayoutContainer.snapToGrid(taskItem)
                                // 计算新的任务索引
                                var newIndex = manualLayoutContainer.calculateNewIndex(taskItem)
                                // 排列任务项顺序
                                taskController.updateTaskOrder(taskId, newIndex)
                            }
                        }
                    }
                }
                
                // 自动布局模式下的提示
                Rectangle {
                    id: autoLayoutTooltip
                    width: autoLayoutTooltipText.width + 20
                    height: autoLayoutTooltipText.height + 10
                    color: "#333333"
                    radius: 4
                    opacity: 0.9
                    visible: false
                    anchors.centerIn: parent
                    
                    Text {
                        id: autoLayoutTooltipText
                        text: "自动布局模式下不能拖拽，请切换到手动布局模式"
                        color: "white"
                        anchors.centerIn: parent
                    }
                    
                    Timer {
                        id: autoLayoutTooltipTimer
                        interval: 2000
                        onTriggered: autoLayoutTooltip.visible = false
                    }
                }
            }
        }
    }
}