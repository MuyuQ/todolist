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
        
        // 获取主应用窗口中的四象限布局
        var mainWindow = parent.parent.parent.parent // 获取到包含所有象限的主容器
        var parentWidth = mainWindow.width
        var parentHeight = mainWindow.height
        var centerX = parentWidth / 2
        var centerY = parentHeight / 2
        
        // 计算拖动距离 - 使用原始位置和当前位置计算实际移动距离
        var movedDistance = Math.sqrt(Math.pow(taskDelegate.x - originalX, 2) + Math.pow(taskDelegate.y - originalY, 2))
        console.log("拖动距离: " + movedDistance)
        
        // 如果拖动距离不够大，保持在当前象限
        // 增加阈值以减少误触发
        if (movedDistance < 100) {
            console.log("拖动距离不足，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        // 获取任务项在主窗口中的绝对位置（使用任务项的中心点）
        // 注意：这里使用taskDelegate的绝对位置，而不是相对于父容器的位置
        var taskCenterX = taskDelegate.x + (taskDelegate.width / 2)
        var taskCenterY = taskDelegate.y + (taskDelegate.height / 2)
        var mainWindowCoords = taskDelegate.mapToItem(mainWindow, taskCenterX, taskCenterY)
        
        // 使用映射后的坐标
        taskCenterX = mainWindowCoords.x
        taskCenterY = mainWindowCoords.y
        
        console.log("计算象限 - 当前象限: " + quadrantNumber)
        console.log("计算象限 - 容器尺寸: (" + parentWidth + "x" + parentHeight + ")")
        console.log("计算象限 - 中心点: (" + centerX + ", " + centerY + ")")
        console.log("计算象限 - 任务中心位置: (" + taskCenterX + ", " + taskCenterY + ")")
        
        // 计算当前象限的边界
        var currentQuadrantBounds = {
            minX: quadrantNumber === 1 || quadrantNumber === 3 ? 0 : centerX,
            maxX: quadrantNumber === 1 || quadrantNumber === 3 ? centerX : parentWidth,
            minY: quadrantNumber === 1 || quadrantNumber === 2 ? 0 : centerY,
            maxY: quadrantNumber === 1 || quadrantNumber === 2 ? centerY : parentHeight
        }
        
        // 检查是否明显跨越了象限边界
        var crossedBoundaryX = (taskCenterX < centerX && (quadrantNumber === 2 || quadrantNumber === 4)) ||
                              (taskCenterX > centerX && (quadrantNumber === 1 || quadrantNumber === 3))
        var crossedBoundaryY = (taskCenterY < centerY && (quadrantNumber === 3 || quadrantNumber === 4)) ||
                              (taskCenterY > centerY && (quadrantNumber === 1 || quadrantNumber === 2))
        
        // 必须明显跨越边界才改变象限
        var boundaryThreshold = 30 // 增加跨越边界的最小距离，减少误触发
        if (!crossedBoundaryX && !crossedBoundaryY) {
            console.log("未跨越象限边界，保持在当前象限: " + quadrantNumber)
            return quadrantNumber
        }
        
        if (crossedBoundaryX) {
            var distanceFromBoundaryX = Math.abs(taskCenterX - centerX)
            if (distanceFromBoundaryX < boundaryThreshold) {
                console.log("水平方向未明显跨越边界，保持在当前象限: " + quadrantNumber)
                return quadrantNumber
            }
        }
        
        if (crossedBoundaryY) {
            var distanceFromBoundaryY = Math.abs(taskCenterY - centerY)
            if (distanceFromBoundaryY < boundaryThreshold) {
                console.log("垂直方向未明显跨越边界，保持在当前象限: " + quadrantNumber)
                return quadrantNumber
            }
        }
        
        // 根据任务项中心点位置判断新象限
        var newQuadrant = 0
        if (taskCenterX < centerX) {
            newQuadrant = taskCenterY < centerY ? 1 : 3
        } else {
            newQuadrant = taskCenterY < centerY ? 2 : 4
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
            
            // 如果移动距离太小，恢复到原始位置
            var movedDistance = Math.sqrt(Math.pow(taskDelegate.x - originalX, 2) + Math.pow(taskDelegate.y - originalY, 2))
            if (movedDistance < 10) {
                gridX = originalX
                gridY = originalY
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
                console.log("移动任务到新象限: " + newQuadrant)
                taskController.moveTaskToQuadrant(taskId, newQuadrant)
                return // 已经处理了象限变化，不需要再发送dragFinished信号
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