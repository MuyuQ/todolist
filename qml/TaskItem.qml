import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import "utils.js" as Utils

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
        verticalOffset: isDragging ? 8 : 3
        radius: isDragging ? 12.0 : 8.0
        samples: 17
        color: isDragging ? "#40000000" : "#25000000"
        Behavior on verticalOffset { NumberAnimation { duration: 150 } }
        Behavior on radius { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    
    // 添加微妙的渐变背景
    Rectangle {
        id: gradientBackground
        anchors.fill: parent
        radius: parent.radius
        opacity: 0.05
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(Utils.getQuadrantColor(taskQuadrant), 1.1) }
            GradientStop { position: 1.0; color: "white" }
        }
    }
    
    // 属性
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    
    // 拖拽相关属性
    property bool isDragging: false
    property int startX: 0
    property int startY: 0
    property int originalX: 0
    property int originalY: 0
    property int originalZ: 0
    property int originalQuadrant: taskQuadrant
    
    // 信号
    signal dragFinished()
    
    // 添加平滑过渡动画
    Behavior on scale { NumberAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on x { enabled: !isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    Behavior on y { enabled: !isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    

    
    // 拖拽状态变化时的视觉效果
    states: [
        State {
            name: "dragging"
            when: isDragging
            PropertyChanges { target: taskDelegate; scale: 1.05; opacity: 0.9; z: 100 }
            PropertyChanges { target: gradientBackground; opacity: 0.15 }
        }
    ]
    
    // 拖拽区域
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: isDragging ? parent : undefined
        drag.axis: Drag.XAxis | Drag.YAxis  // 修复为有效的枚举值
        drag.minimumX: 0
        drag.minimumY: 0
        drag.filterChildren: true
        hoverEnabled: true
        
        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                // 记录初始位置和状态
                startX = mouse.x
                startY = mouse.y
                originalX = parent.x
                originalY = parent.y
                originalZ = parent.z
                originalQuadrant = taskQuadrant
                
                // 开始拖拽
                isDragging = true
            }
        }
        
        onReleased: function(mouse) {
            if (isDragging) {
                // 结束拖拽
                isDragging = false
                
                // 检测是否移动到新象限
                var newQuadrant = detectQuadrant()
                if (newQuadrant !== originalQuadrant && newQuadrant >= 1 && newQuadrant <= 4) {
                    // 更新任务象限
                    taskController.moveTaskToQuadrant(taskId, newQuadrant)
                    // 任务象限已更新，无需额外信号
                }
                
                // 发出拖拽完成信号
                taskDelegate.dragFinished()
            }
        }
        
        // 检测当前位置所在的象限
        function detectQuadrant() {
            // 获取任务项中心点坐标
            var centerX = parent.x + parent.width / 2
            var centerY = parent.y + parent.height / 2
            
            // 获取父容器（应该是QuadrantPanel内的Item）
            var container = parent.parent
            if (!container) return originalQuadrant
            
            // 获取容器尺寸
            var containerWidth = container.width
            var containerHeight = container.height
            
            // 计算相对位置（0-1范围）
            var relativeX = centerX / containerWidth
            var relativeY = centerY / containerHeight
            
            // 根据相对位置确定象限
            // 这里假设象限布局是2x2的网格，可以根据实际布局调整
            if (relativeX < 0.5) {
                return relativeY < 0.5 ? 1 : 3; // 左上:1, 左下:3
            } else {
                return relativeY < 0.5 ? 2 : 4; // 右上:2, 右下:4
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
            
            // 任务信息区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Label {
                    text: taskTitle
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                // 添加任务描述标签
                Label {
                    text: taskDescription
                    font.pixelSize: 12
                    color: "#666666"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: taskDescription && taskDescription.length > 0
                    maximumLineCount: 1
                }
            }
            
            CheckBox {
                id: taskCheckBox
                checked: false
                onClicked: taskController.setTaskCompleted(taskId, checked)
                
                // 防止拖拽时触发复选框
                enabled: !isDragging
                
                // 组件创建时检查任务状态
                Component.onCompleted: {
                    // 这里不需要实际操作，因为未完成的任务才会显示在这个视图中
                    // 如果将来需要显示已完成任务，可以在这里设置初始状态
                }
                
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
                
                // 防止鼠标事件传递到下层的MouseArea
                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse.accepted = !isDragging
                    onClicked: {
                        if (!isDragging) {
                            taskCheckBox.toggle()
                            taskController.setTaskCompleted(taskId, taskCheckBox.checked)
                        }
                        mouse.accepted = true
                    }
                }
            }
        }
    }
}