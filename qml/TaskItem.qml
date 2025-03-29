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
    
    // ��ӿ�Ƭ��ӰЧ��
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
    
    // ���΢��Ľ��䱳��
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
    
    // ����
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    
    // ��ק�������
    property bool isDragging: false
    property int startX: 0
    property int startY: 0
    property int originalX: 0
    property int originalY: 0
    property int originalZ: 0
    property int originalQuadrant: taskQuadrant
    
    // �ź�
    signal dragFinished()
    
    // ���ƽ�����ɶ���
    Behavior on scale { NumberAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on x { enabled: !isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    Behavior on y { enabled: !isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    

    
    // ��ק״̬�仯ʱ���Ӿ�Ч��
    states: [
        State {
            name: "dragging"
            when: isDragging
            PropertyChanges { target: taskDelegate; scale: 1.05; opacity: 0.9; z: 100 }
            PropertyChanges { target: gradientBackground; opacity: 0.15 }
        }
    ]
    
    // ��ק����
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: isDragging ? parent : undefined
        drag.axis: Drag.XAxis | Drag.YAxis  // �޸�Ϊ��Ч��ö��ֵ
        drag.minimumX: 0
        drag.minimumY: 0
        drag.filterChildren: true
        hoverEnabled: true
        
        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                // ��¼��ʼλ�ú�״̬
                startX = mouse.x
                startY = mouse.y
                originalX = parent.x
                originalY = parent.y
                originalZ = parent.z
                originalQuadrant = taskQuadrant
                
                // ��ʼ��ק
                isDragging = true
            }
        }
        
        onReleased: function(mouse) {
            if (isDragging) {
                // ������ק
                isDragging = false
                
                // ����Ƿ��ƶ���������
                var newQuadrant = detectQuadrant()
                if (newQuadrant !== originalQuadrant && newQuadrant >= 1 && newQuadrant <= 4) {
                    // ������������
                    taskController.moveTaskToQuadrant(taskId, newQuadrant)
                    // ���������Ѹ��£���������ź�
                }
                
                // ������ק����ź�
                taskDelegate.dragFinished()
            }
        }
        
        // ��⵱ǰλ�����ڵ�����
        function detectQuadrant() {
            // ��ȡ���������ĵ�����
            var centerX = parent.x + parent.width / 2
            var centerY = parent.y + parent.height / 2
            
            // ��ȡ��������Ӧ����QuadrantPanel�ڵ�Item��
            var container = parent.parent
            if (!container) return originalQuadrant
            
            // ��ȡ�����ߴ�
            var containerWidth = container.width
            var containerHeight = container.height
            
            // �������λ�ã�0-1��Χ��
            var relativeX = centerX / containerWidth
            var relativeY = centerY / containerHeight
            
            // �������λ��ȷ������
            // ����������޲�����2x2�����񣬿��Ը���ʵ�ʲ��ֵ���
            if (relativeX < 0.5) {
                return relativeY < 0.5 ? 1 : 3; // ����:1, ����:3
            } else {
                return relativeY < 0.5 ? 2 : 4; // ����:2, ����:4
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
            
            // ������Ϣ����
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
                
                // �������������ǩ
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
                
                // ��ֹ��קʱ������ѡ��
                enabled: !isDragging
                
                // �������ʱ�������״̬
                Component.onCompleted: {
                    // ���ﲻ��Ҫʵ�ʲ�������Ϊδ��ɵ�����Ż���ʾ�������ͼ��
                    // ���������Ҫ��ʾ��������񣬿������������ó�ʼ״̬
                }
                
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
                
                // ��ֹ����¼����ݵ��²��MouseArea
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