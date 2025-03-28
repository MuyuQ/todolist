import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: taskDelegate
    height: 80
    radius: 12
    color: "white"
    border.color: "transparent"
    border.width: 0
    
    // 添加卡片阴影效果
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#25000000"
    }
    
    // 添加微妙的渐变背景
    Rectangle {
        id: gradientBackground
        anchors.fill: parent
        radius: parent.radius
        opacity: 0.05
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(getQuadrantColor(taskQuadrant), 1.1) }
            GradientStop { position: 1.0; color: "white" }
        }
    }
    
    // 属性
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    
    // 拖拽完成信号
    signal dragFinished()
    
    // 拖拽状态
    property bool isDragging: false
    
    // 原始位置
    property real originalX: x
    property real originalY: y
    
    // 默认z轴层级
    z: isDragging ? 10000 : 1
    
    // 添加平滑过渡动画
    Behavior on scale { NumberAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on z { NumberAnimation { duration: 50 } }
    
    // 对齐动画
    ParallelAnimation {
        id: alignAnimation
        property real targetX: 0
        property real targetY: 0
        
        NumberAnimation {
            target: taskDelegate
            property: "x"
            to: alignAnimation.targetX
            duration: 150
            easing.type: Easing.OutQuad
        }
        
        NumberAnimation {
            target: taskDelegate
            property: "y"
            to: alignAnimation.targetY
            duration: 150
            easing.type: Easing.OutQuad
        }
        
        onStopped: {
            // 动画完成后发送信号
            if (!taskDelegate.isDragging) {
                dragFinished()
            }
        }
    }
    
    // 计算新象限的函数
    function calculateNewQuadrant(x, y) {
        // 获取当前任务项所在的象限面板（QuadrantPanel）
        var quadrantPanel = parent.parent // 获取到当前象限面板
        var quadrantNumber = taskQuadrant // 当前象限编号
        
        // 计算拖动距离 - 使用原始位置和当前位置计算实际移动距离
        var movedDistance = Math.sqrt(Math.pow(taskDelegate.x - originalX, 2) + Math.pow(taskDelegate.y - originalY, 2))
        console.log("拖动距离: " + movedDistance)
        
        // 如果拖动距离不够大，保持在当前象限
        // 增加阈值以减少误触发 - 设置更高的阈值
        if (movedDistance < 200) { // 增加阈值，减少误触发
            console.log("拖动距离不足，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        // 获取主应用窗口中的四象限布局
        var mainWindow = parent.parent.parent.parent // 获取到包含所有象限的主容器
        
        // 获取当前象限面板在主窗口中的位置和尺寸
        var quadrantPos = quadrantPanel.mapToItem(mainWindow, 0, 0)
        var quadrantWidth = quadrantPanel.width
        var quadrantHeight = quadrantPanel.height
        
        // 获取任务项在主窗口中的绝对位置（使用任务项的中心点）
        var taskGlobalPos = taskDelegate.mapToItem(mainWindow, taskDelegate.width/2, taskDelegate.height/2)
        var taskGlobalX = taskGlobalPos.x
        var taskGlobalY = taskGlobalPos.y
        
        // 获取主窗口的中心点
        var centerX = mainWindow.width / 2
        var centerY = mainWindow.height / 2
        
        console.log("计算象限 - 当前象限: " + quadrantNumber)
        console.log("计算象限 - 主窗口尺寸: (" + mainWindow.width + "x" + mainWindow.height + ")")
        console.log("计算象限 - 中心点: (" + centerX + ", " + centerY + ")")
        console.log("计算象限 - 任务全局位置: (" + taskGlobalX + ", " + taskGlobalY + ")")
        console.log("计算象限 - 当前象限位置: (" + quadrantPos.x + ", " + quadrantPos.y + ")")
        console.log("计算象限 - 当前象限尺寸: (" + quadrantWidth + "x" + quadrantHeight + ")")
        
        // 检查任务是否仍在当前象限面板的边界内（添加更大的边距）
        var margin = 40 // 增加边距，防止在边界附近误判
        var isInCurrentQuadrant = 
            taskGlobalX >= quadrantPos.x + margin && 
            taskGlobalX <= quadrantPos.x + quadrantWidth - margin && 
            taskGlobalY >= quadrantPos.y + margin && 
            taskGlobalY <= quadrantPos.y + quadrantHeight - margin
        
        if (isInCurrentQuadrant) {
            console.log("任务仍在当前象限面板内，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        // 计算任务项中心点到当前象限中心的距离
        var quadrantCenterX = quadrantPos.x + quadrantWidth / 2
        var quadrantCenterY = quadrantPos.y + quadrantHeight / 2
        var distanceToQuadrantCenter = Math.sqrt(
            Math.pow(taskGlobalX - quadrantCenterX, 2) + 
            Math.pow(taskGlobalY - quadrantCenterY, 2)
        )
        
        // 如果距离当前象限中心不够远，保持在当前象限
        var minDistanceToChangeQuadrant = Math.min(quadrantWidth, quadrantHeight) * 0.4
        if (distanceToQuadrantCenter < minDistanceToChangeQuadrant) {
            console.log("距离当前象限中心不够远，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        // 确定新象限 - 使用主窗口中心线判断
        var newQuadrant = 0
        
        // 添加边界缓冲区，避免在中心线附近频繁切换象限
        var bufferZone = 50 // 增加边界缓冲区大小
        
        // 根据任务项在主窗口中的位置判断新象限
        if (Math.abs(taskGlobalX - centerX) < bufferZone || Math.abs(taskGlobalY - centerY) < bufferZone) {
            // 在中心缓冲区内，保持当前象限
            console.log("任务在中心缓冲区内，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        if (taskGlobalX < centerX) {
            newQuadrant = taskGlobalY < centerY ? 1 : 3
        } else {
            newQuadrant = taskGlobalY < centerY ? 2 : 4
        }
        
        // 确保计算的新象限与当前象限不同
        if (newQuadrant === quadrantNumber) {
            console.log("计算结果与当前象限相同，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        console.log("跨越象限边界，新象限: " + newQuadrant)
        return newQuadrant
    }
    
    // 拖拽区域
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: parent
        drag.smoothed: true
        drag.threshold: 5
        
        // 网格对齐和吸附设置
        property int gridSize: 220
        property bool showGridLines: false
        property int snapThreshold: 20 // 吸附阈值
        property bool enableSnapping: true // 是否启用网格吸附
        
        // 网格线
        Rectangle {
            id: horizontalGridLine
            width: parent.parent ? (parent.parent.parent ? parent.parent.parent.width : parent.parent.width) : parent.width
            height: 1
            color: "#0078d4"
            opacity: 0.5
            visible: dragArea.showGridLines
            y: Math.round(taskDelegate.y / dragArea.gridSize) * dragArea.gridSize + taskDelegate.height / 2
        }
        
        Rectangle {
            id: verticalGridLine
            width: 1
            height: parent.parent ? (parent.parent.parent ? parent.parent.parent.height : parent.parent.height) : parent.height
            color: "#0078d4"
            opacity: 0.5
            visible: dragArea.showGridLines
            x: Math.round(taskDelegate.x / dragArea.gridSize) * dragArea.gridSize + taskDelegate.width / 2
        }
        
        onPressed: {
            taskDelegate.isDragging = true
            taskDelegate.originalX = taskDelegate.x
            taskDelegate.originalY = taskDelegate.y
            // Z轴层级已通过属性绑定设置，无需手动设置
            // 拖动时的视觉效果增强
            taskDelegate.scale = 1.08
            taskDelegate.opacity = 0.85
            // 增强阴影效果
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 12.0;
                }
                if (effect.hasOwnProperty("color")) {
                    effect.color = "#40000000";
                }
            }
            // 显示网格线
            showGridLines = true
        }
        
        onPositionChanged: {
            if (taskDelegate.isDragging) {
                // 在拖动过程中显示网格线和对齐点
                var gridX = Math.round(taskDelegate.x / gridSize) * gridSize
                var gridY = Math.round(taskDelegate.y / gridSize) * gridSize
                
                // 隐藏网格线位置
                horizontalGridLine.y = gridY + taskDelegate.height / 2
                verticalGridLine.x = gridX + taskDelegate.width / 2
                
                // 接近网格点时提供视觉反馈和实时对齐
                if (enableSnapping) {
                    // 同时检查水平和垂直对齐
                    var snapHorizontal = Math.abs(taskDelegate.x - gridX) < snapThreshold
                    var snapVertical = Math.abs(taskDelegate.y - gridY) < snapThreshold
                    
                    if (snapHorizontal && snapVertical) {
                        // 同时对齐到网格交叉点
                        taskDelegate.x = gridX
                        taskDelegate.y = gridY
                        taskDelegate.border.color = "#0078d4" // 高亮边框
                        taskDelegate.border.width = 2
                    } else if (snapHorizontal) {
                        // 水平方向对齐
                        taskDelegate.x = gridX
                        taskDelegate.border.color = "#0078d4" // 高亮边框
                        taskDelegate.border.width = 2
                    } else if (snapVertical) {
                        // 垂直方向对齐
                        taskDelegate.y = gridY
                        taskDelegate.border.color = "#0078d4" // 高亮边框
                        taskDelegate.border.width = 2
                    } else {
                        taskDelegate.border.color = "#e6e6e6"
                        taskDelegate.border.width = 1
                    }
                }
            }
        }
        
        onReleased: {
            taskDelegate.isDragging = false
            // 不再手动重置z值，让绑定处理
            // 恢复视觉效果
            taskDelegate.scale = 1.0
            taskDelegate.opacity = 1.0
            // 恢复原始阴影效果
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 6.0;
                }
                if (effect.hasOwnProperty("color")) {
                    effect.color = "#20000000";
                }
            }
            // 恢复边框样式
            taskDelegate.border.color = "#e6e6e6"
            taskDelegate.border.width = 1
            // 隐藏网格线
            showGridLines = false
            
            // 计算网格位置
            var gridX = Math.round(taskDelegate.x / gridSize) * gridSize
            var gridY = Math.round(taskDelegate.y / gridSize) * gridSize
            
            // 计算移动距离
            var movedDistance = Math.sqrt(Math.pow(taskDelegate.x - originalX, 2) + Math.pow(taskDelegate.y - originalY, 2))
            console.log("移动距离: " + movedDistance)
            
            // 如果移动距离太小，恢复到原始位置并且不检查象限变化
            if (movedDistance < 50) { // 增加阈值，减少误触发
                console.log("移动距离太小，恢复到原始位置")
                gridX = originalX
                gridY = originalY
                alignAnimation.targetX = gridX
                alignAnimation.targetY = gridY
                alignAnimation.start()
                
                // 发送拖拽完成信号，更新排序
                dragFinished()
                return // 不检查象限变化
            }
            
            // 启动平滑对齐动画
            alignAnimation.targetX = gridX
            alignAnimation.targetY = gridY
            alignAnimation.start()
            
            // 检查新的象限
            console.log("原始位置: (" + originalX + ", " + originalY + "), 当前位置: (" + taskDelegate.x + ", " + taskDelegate.y + ")")
            
            // 使用任务项当前位置计算象限
            var newQuadrant = calculateNewQuadrant(taskDelegate.x, taskDelegate.y)
            console.log("当前象限: " + taskQuadrant + ", 计算得到的新象限: " + newQuadrant)
            
            // 确保计算的象限有效且与当前象限不同
            if (newQuadrant > 0 && newQuadrant <= 4 && newQuadrant !== taskQuadrant) {
                // 额外检查：确保移动距离足够大才触发象限变更
                if (movedDistance > 200) { // 设置更高的阈值用于象限变更
                    // 获取当前象限面板和目标象限面板
                    var currentQuadrantPanel = parent.parent
                    var mainWindow = parent.parent.parent.parent
                    
                    // 计算任务项中心点到当前象限边界的最小距离
                    var currentQuadrantPos = currentQuadrantPanel.mapToItem(mainWindow, 0, 0)
                    var currentQuadrantWidth = currentQuadrantPanel.width
                    var currentQuadrantHeight = currentQuadrantPanel.height
                    
                    // 任务项在主窗口中的绝对位置
                    var taskGlobalPos = taskDelegate.mapToItem(mainWindow, taskDelegate.width/2, taskDelegate.height/2)
                    var taskGlobalX = taskGlobalPos.x
                    var taskGlobalY = taskGlobalPos.y
                    
                    // 计算到边界的距离
                    var distanceToLeftBorder = Math.abs(taskGlobalX - currentQuadrantPos.x)
                    var distanceToRightBorder = Math.abs(taskGlobalX - (currentQuadrantPos.x + currentQuadrantWidth))
                    var distanceToTopBorder = Math.abs(taskGlobalY - currentQuadrantPos.y)
                    var distanceToBottomBorder = Math.abs(taskGlobalY - (currentQuadrantPos.y + currentQuadrantHeight))
                    
                    // 到边界的最小距离
                    var minDistanceToBorder = Math.min(distanceToLeftBorder, distanceToRightBorder, distanceToTopBorder, distanceToBottomBorder)
                    
                    // 只有当任务项明显超出当前象限边界时才允许变更象限
                    if (minDistanceToBorder > 50) { // 设置边界阈值
                        console.log("移动任务到新象限: " + newQuadrant + ", 边界距离: " + minDistanceToBorder)
                        taskController.moveTaskToQuadrant(taskId, newQuadrant)
                        return // 已经处理了象限变化，不需要再发送dragFinished信号
                    } else {
                        console.log("虽然移动距离足够，但未明显超出象限边界，保持在当前象限: " + taskQuadrant)
                    }
                } else {
                    console.log("移动距离不足以触发象限变更，保持在当前象限: " + taskQuadrant)
                }
            } else {
                console.log("保持在当前象限: " + taskQuadrant)
            }
            
            // 发送拖拽完成信号，更新排序
            dragFinished()
        }
    }
    
    // 内容布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        // 添加位置变化动画
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        
        // 标题行
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Label {
                text: taskTitle
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            CheckBox {
                id: taskCheckBox
                checked: false
                onClicked: taskController.setTaskCompleted(taskId, checked)
                
                // 改进的WinUI3风格复选框
                indicator: Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 4
                    border.color: taskCheckBox.checked ? "#0078d4" : 
                                 taskCheckBox.hovered ? "#666666" : "#999999"
                    border.width: 1.5
                    color: taskCheckBox.checked ? "#0078d4" : "transparent"
                    
                    // 平滑过渡动画
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        text: "?"
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        visible: taskCheckBox.checked
                        opacity: taskCheckBox.checked ? 1.0 : 0.0
                        
                        // 淡入淡出动画
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}