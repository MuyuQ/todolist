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
        var parentWidth = parent.width
        var parentHeight = parent.height
        var centerX = parentWidth / 2
        var centerY = parentHeight / 2
        
        // 根据位置判断象限
        if (x < centerX) {
            return y < centerY ? 1 : 3
        } else {
            return y < centerY ? 2 : 4
        }
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
            taskDelegate.z = 1000 // 确保拖拽项的Z顺序最高层
            // 拖动时的视觉效果
            taskDelegate.scale = 1.05
            taskDelegate.opacity = 0.9
            // 增强阴影效果
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 12.0;
                }
                effect.color = "#40000000";
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
                    // ???????????????
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
            taskDelegate.z = 0 // 恢复Z顺序
            // 恢复视觉效果
            taskDelegate.scale = 1.0
            taskDelegate.opacity = 1.0
            // 恢复原始阴影效果
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 6.0;
                }
                effect.color = "#20000000";
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
            var newQuadrant = calculateNewQuadrant(parent.x, parent.y)
            if (newQuadrant !== taskQuadrant) {
                taskController.moveTaskToQuadrant(taskId, newQuadrant)
            } else {
                // 发送拖拽完成信号，更新排序
                dragFinished()
            }
        }
    }
    
    // 内容布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
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