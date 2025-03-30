import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: taskDelegate
    height: 80
    radius: 12
    color: "white"
    border.width: 0
    
    // 阴影效果 - 优化版
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: isDragging ? 8 : 3
        radius: isDragging ? 12.0 : 8.0
        samples: 12
        color: isDragging ? "#40000000" : "#25000000"
        Behavior on verticalOffset { NumberAnimation { duration: 150 } }
        Behavior on radius { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    
    // ??????
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
    
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    property bool isDragging: false
    property int originalQuadrant: taskQuadrant
    
    signal dragFinished()
    
    // ???????
    Behavior on scale { NumberAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on x { enabled: !isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    Behavior on y { enabled: !isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    
    // ??????仯??????Ч??
    states: [
        State {
            name: "dragging"
            when: isDragging
            PropertyChanges { target: taskDelegate; scale: 1.05; opacity: 0.9; z: 100 }
            PropertyChanges { target: gradientBackground; opacity: 0.15 }
        }
    ]
    
    // ???????
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: isDragging ? parent : undefined
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.filterChildren: true
        
        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                originalQuadrant = taskQuadrant
                isDragging = true
            }
        }
        
        onReleased: function() {
            if (isDragging) {
                isDragging = false
                var newQuadrant = detectQuadrant()
                if (newQuadrant !== originalQuadrant && newQuadrant >= 1 && newQuadrant <= 4) {
                    taskController.moveTaskToQuadrant(taskId, newQuadrant)
                }
                taskDelegate.dragFinished()
            }
        }
        
        function detectQuadrant() {
            var container = parent.parent
            if (!container) return originalQuadrant
            
            // 优化版 - 简化象限检测逻辑
            var centerX = parent.x + parent.width / 2
            var centerY = parent.y + parent.height / 2
            var isLeft = centerX < container.width / 2
            var isTop = centerY < container.height / 2
            
            // 象限映射: 左上=1, 右上=2, 左下=3, 右下=4
            return isLeft ? (isTop ? 1 : 3) : (isTop ? 2 : 4)
        }
    }
    
    // ???????
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
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
                
                // ???????????????
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
                
                // ????????????????
                enabled: !isDragging
                
                indicator: Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 4
                    border.color: taskCheckBox.checked ? "#0078d4" : 
                                 taskCheckBox.hovered ? "#666666" : "#999999"
                    border.width: 1.5
                    color: taskCheckBox.checked ? "#0078d4" : "transparent"
                    
                    // ??????????
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        text: "?"
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        visible: taskCheckBox.checked
                        opacity: taskCheckBox.checked ? 1.0 : 0.0
                        
                        // ??????????
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse.accepted = !isDragging
                    onClicked: if (!isDragging) taskCheckBox.toggle()
                }
            }
        }
    }
}