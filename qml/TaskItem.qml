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
    
    // Ĭ��z��㼶
    z: isDragging ? 10000 : 1
    
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
        // ��ȡ��ǰ���������ڵ�������壨QuadrantPanel��
        var quadrantPanel = parent.parent // ��ȡ����ǰ�������
        var quadrantNumber = taskQuadrant // ��ǰ���ޱ��
        
        // ��ȡ��Ӧ�ô����е������޲���
        var mainWindow = parent.parent.parent.parent // ��ȡ�������������޵�������
        var parentWidth = mainWindow.width
        var parentHeight = mainWindow.height
        var centerX = parentWidth / 2
        var centerY = parentHeight / 2
        
        // �����϶����� - ʹ��ԭʼλ�ú͵�ǰλ�ü���ʵ���ƶ�����
        var movedDistance = Math.sqrt(Math.pow(taskDelegate.x - originalX, 2) + Math.pow(taskDelegate.y - originalY, 2))
        console.log("�϶�����: " + movedDistance)
        
        // ����϶����벻���󣬱����ڵ�ǰ����
        // ������ֵ�Լ����󴥷�
        if (movedDistance < 100) {
            console.log("�϶����벻�㣬�����ڵ�ǰ����: " + quadrantNumber)
            return quadrantNumber
        }
        
        // ��ȡ���������������еľ���λ�ã�ʹ������������ĵ㣩
        // ע�⣺����ʹ��taskDelegate�ľ���λ�ã�����������ڸ�������λ��
        var taskCenterX = taskDelegate.x + (taskDelegate.width / 2)
        var taskCenterY = taskDelegate.y + (taskDelegate.height / 2)
        var mainWindowCoords = taskDelegate.mapToItem(mainWindow, taskCenterX, taskCenterY)
        
        // ʹ��ӳ��������
        taskCenterX = mainWindowCoords.x
        taskCenterY = mainWindowCoords.y
        
        console.log("�������� - ��ǰ����: " + quadrantNumber)
        console.log("�������� - �����ߴ�: (" + parentWidth + "x" + parentHeight + ")")
        console.log("�������� - ���ĵ�: (" + centerX + ", " + centerY + ")")
        console.log("�������� - ��������λ��: (" + taskCenterX + ", " + taskCenterY + ")")
        
        // ���㵱ǰ���޵ı߽�
        var currentQuadrantBounds = {
            minX: quadrantNumber === 1 || quadrantNumber === 3 ? 0 : centerX,
            maxX: quadrantNumber === 1 || quadrantNumber === 3 ? centerX : parentWidth,
            minY: quadrantNumber === 1 || quadrantNumber === 2 ? 0 : centerY,
            maxY: quadrantNumber === 1 || quadrantNumber === 2 ? centerY : parentHeight
        }
        
        // ����Ƿ����Կ�Խ�����ޱ߽�
        var crossedBoundaryX = (taskCenterX < centerX && (quadrantNumber === 2 || quadrantNumber === 4)) ||
                              (taskCenterX > centerX && (quadrantNumber === 1 || quadrantNumber === 3))
        var crossedBoundaryY = (taskCenterY < centerY && (quadrantNumber === 3 || quadrantNumber === 4)) ||
                              (taskCenterY > centerY && (quadrantNumber === 1 || quadrantNumber === 2))
        
        // �������Կ�Խ�߽�Ÿı�����
        var boundaryThreshold = 30 // ���ӿ�Խ�߽����С���룬�����󴥷�
        if (!crossedBoundaryX && !crossedBoundaryY) {
            console.log("δ��Խ���ޱ߽磬�����ڵ�ǰ����: " + quadrantNumber)
            return quadrantNumber
        }
        
        if (crossedBoundaryX) {
            var distanceFromBoundaryX = Math.abs(taskCenterX - centerX)
            if (distanceFromBoundaryX < boundaryThreshold) {
                console.log("ˮƽ����δ���Կ�Խ�߽磬�����ڵ�ǰ����: " + quadrantNumber)
                return quadrantNumber
            }
        }
        
        if (crossedBoundaryY) {
            var distanceFromBoundaryY = Math.abs(taskCenterY - centerY)
            if (distanceFromBoundaryY < boundaryThreshold) {
                console.log("��ֱ����δ���Կ�Խ�߽磬�����ڵ�ǰ����: " + quadrantNumber)
                return quadrantNumber
            }
        }
        
        // �������������ĵ�λ���ж�������
        var newQuadrant = 0
        if (taskCenterX < centerX) {
            newQuadrant = taskCenterY < centerY ? 1 : 3
        } else {
            newQuadrant = taskCenterY < centerY ? 2 : 4
        }
        
        // ȷ��������������뵱ǰ���޲�ͬ
        if (newQuadrant === quadrantNumber) {
            console.log("�������뵱ǰ������ͬ�������ڵ�ǰ����: " + quadrantNumber)
            return quadrantNumber
        }
        
        console.log("��Խ���ޱ߽磬������: " + newQuadrant)
        return newQuadrant
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
            // Z��㼶��ͨ�����԰����ã������ֶ�����
            // �϶�ʱ���Ӿ�Ч����ǿ
            taskDelegate.scale = 1.08
            taskDelegate.opacity = 0.85
            // ��ǿ��ӰЧ��
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 12.0;
                }
                if (effect.hasOwnProperty("color")) {
                    effect.color = "#40000000";
                }
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
                    // ͬʱ���ˮƽ�ʹ�ֱ����
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
            // �����ֶ�����zֵ���ð󶨴���
            // �ָ��Ӿ�Ч��
            taskDelegate.scale = 1.0
            taskDelegate.opacity = 1.0
            // �ָ�ԭʼ��ӰЧ��
            if (taskDelegate.layer && taskDelegate.layer.effect) {
                var effect = taskDelegate.layer.effect;
                if (effect.hasOwnProperty("radius")) {
                    effect.radius = 6.0;
                }
                if (effect.hasOwnProperty("color")) {
                    effect.color = "#20000000";
                }
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
            console.log("ԭʼλ��: (" + originalX + ", " + originalY + "), ��ǰλ��: (" + taskDelegate.x + ", " + taskDelegate.y + ")")
            
            // ʹ�������ǰλ�ü�������
            var newQuadrant = calculateNewQuadrant(taskDelegate.x, taskDelegate.y)
            console.log("��ǰ����: " + taskQuadrant + ", ����õ���������: " + newQuadrant)
            
            // ȷ�������������Ч���뵱ǰ���޲�ͬ
            if (newQuadrant > 0 && newQuadrant <= 4 && newQuadrant !== taskQuadrant) {
                console.log("�ƶ�����������: " + newQuadrant)
                taskController.moveTaskToQuadrant(taskId, newQuadrant)
                return // �Ѿ����������ޱ仯������Ҫ�ٷ���dragFinished�ź�
            } else {
                console.log("�����ڵ�ǰ����: " + taskQuadrant)
            }
            
            // ������ק����źţ���������
            dragFinished()
        }
    }
    
    // ���ݲ���
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        // ���λ�ñ仯����
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        
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