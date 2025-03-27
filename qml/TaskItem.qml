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
    
    // ��ӿ�Ƭ��ӰЧ��
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#25000000"
    }
    
    // ���΢��Ľ��䱳��
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
    
    // ����
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    
    // ��ק����ź�
    signal dragFinished()
    
    // ��ק״̬
    property bool isDragging: false
    
    // ԭʼλ��
    property real originalX: x
    property real originalY: y
    
    // ���ƽ�����ɶ���
    Behavior on scale { NumberAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on z { NumberAnimation { duration: 50 } }
    
    // ���붯��
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
            // ������ɺ����ź�
            if (!taskDelegate.isDragging) {
                dragFinished()
            }
        }
    }
    
    // ���������޵ĺ���
    function calculateNewQuadrant(x, y) {
        var parentWidth = parent.width
        var parentHeight = parent.height
        var centerX = parentWidth / 2
        var centerY = parentHeight / 2
        
        // ����λ���ж�����
        if (x < centerX) {
            return y < centerY ? 1 : 3
        } else {
            return y < centerY ? 2 : 4
        }
    }
    
    // ��ק����
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: parent
        drag.smoothed: true
        drag.threshold: 5
        
        // ����������������
        property int gridSize: 220
        property bool showGridLines: false
        property int snapThreshold: 20 // ������ֵ
        property bool enableSnapping: true // �Ƿ�������������
        
        // ������
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
            taskDelegate.z = 1000 // ȷ����ק���Z˳����߲�
            // �϶�ʱ���Ӿ�Ч��
            taskDelegate.scale = 1.05
            taskDelegate.opacity = 0.9
            // ��ǿ��ӰЧ��
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 12.0;
                }
                effect.color = "#40000000";
            }
            // ��ʾ������
            showGridLines = true
        }
        
        onPositionChanged: {
            if (taskDelegate.isDragging) {
                // ���϶���������ʾ�����ߺͶ����
                var gridX = Math.round(taskDelegate.x / gridSize) * gridSize
                var gridY = Math.round(taskDelegate.y / gridSize) * gridSize
                
                // ����������λ��
                horizontalGridLine.y = gridY + taskDelegate.height / 2
                verticalGridLine.x = gridX + taskDelegate.width / 2
                
                // �ӽ������ʱ�ṩ�Ӿ�������ʵʱ����
                if (enableSnapping) {
                    // ???????????????
                    var snapHorizontal = Math.abs(taskDelegate.x - gridX) < snapThreshold
                    var snapVertical = Math.abs(taskDelegate.y - gridY) < snapThreshold
                    
                    if (snapHorizontal && snapVertical) {
                        // ͬʱ���뵽���񽻲��
                        taskDelegate.x = gridX
                        taskDelegate.y = gridY
                        taskDelegate.border.color = "#0078d4" // �����߿�
                        taskDelegate.border.width = 2
                    } else if (snapHorizontal) {
                        // ˮƽ�������
                        taskDelegate.x = gridX
                        taskDelegate.border.color = "#0078d4" // �����߿�
                        taskDelegate.border.width = 2
                    } else if (snapVertical) {
                        // ��ֱ�������
                        taskDelegate.y = gridY
                        taskDelegate.border.color = "#0078d4" // �����߿�
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
            taskDelegate.z = 0 // �ָ�Z˳��
            // �ָ��Ӿ�Ч��
            taskDelegate.scale = 1.0
            taskDelegate.opacity = 1.0
            // �ָ�ԭʼ��ӰЧ��
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 6.0;
                }
                effect.color = "#20000000";
            }
            // �ָ��߿���ʽ
            taskDelegate.border.color = "#e6e6e6"
            taskDelegate.border.width = 1
            // ����������
            showGridLines = false
            
            // ��������λ��
            var gridX = Math.round(taskDelegate.x / gridSize) * gridSize
            var gridY = Math.round(taskDelegate.y / gridSize) * gridSize
            
            // ����ƶ�����̫С���ָ���ԭʼλ��
            var movedDistance = Math.sqrt(Math.pow(taskDelegate.x - originalX, 2) + Math.pow(taskDelegate.y - originalY, 2))
            if (movedDistance < 10) {
                gridX = originalX
                gridY = originalY
            }
            
            // ����ƽ�����붯��
            alignAnimation.targetX = gridX
            alignAnimation.targetY = gridY
            alignAnimation.start()
            
            // ����µ�����
            var newQuadrant = calculateNewQuadrant(parent.x, parent.y)
            if (newQuadrant !== taskQuadrant) {
                taskController.moveTaskToQuadrant(taskId, newQuadrant)
            } else {
                // ������ק����źţ���������
                dragFinished()
            }
        }
    }
    
    // ���ݲ���
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        // ������
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
                
                // �Ľ���WinUI3���ѡ��
                indicator: Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 4
                    border.color: taskCheckBox.checked ? "#0078d4" : 
                                 taskCheckBox.hovered ? "#666666" : "#999999"
                    border.width: 1.5
                    color: taskCheckBox.checked ? "#0078d4" : "transparent"
                    
                    // ƽ�����ɶ���
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        text: "?"
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        visible: taskCheckBox.checked
                        opacity: taskCheckBox.checked ? 1.0 : 0.0
                        
                        // ���뵭������
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}