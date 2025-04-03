import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    
    property int quadrantNumber: 1
    property string quadrantTitle: "未分类"
    property color quadrantColor: "#e0e0e0"
    
    color: quadrantColor
    radius: 12
    border.width: 0
    z: 1
    
    // 使用统一的阴影效果组件
    ShadowEffect {
        id: shadowEffect
        offsetY: 4
        blurRadius: 12.0
        shadowColor: "#30000000"
        Component.onCompleted: applyTo(root)
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
            
            // 简化为列表布局
            ListView {
                width: parent.width
                height: parent.height
                spacing: 8
                model: taskListModel.model
                
                delegate: TaskItem {
                    width: ListView.view ? ListView.view.width - 10 : 100
                    taskId: model.id || -1
                    taskTitle: model.title || ""
                    taskDescription: model.description || ""
                    taskQuadrant: model.quadrant || 4
                }
            }
        }
    }
}