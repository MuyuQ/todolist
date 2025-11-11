import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: completedTaskItem
    
    property int taskId: -1
    property string taskTitle: ""
    property string taskDescription: ""
    property int taskQuadrant: 4
    property string createdAt: ""
    
    // 使用implicitHeight代替固定高度计算以确保更好的布局适应
    implicitHeight: contentLayout.implicitHeight + 24
    color: "white"
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        
        // 任务标题和完成标记
        RowLayout {
            spacing: 8
            
            // 完成标记
            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: "#4cc9f0"
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 12
                    color: "white"
                }
            }
            
            // 任务标题
            Text {
                text: taskTitle
                font.pixelSize: 16
                font.weight: Font.Medium
                color: "#8d99ae"
                elide: Text.ElideRight
                Layout.fillWidth: true
                
                // 划线效果
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#8d99ae"
                }
            }
        }
        
        // 任务描述
        Text {
            text: taskDescription
            font.pixelSize: 14
            color: "#8d99ae"
            elide: Text.ElideRight
            Layout.fillWidth: true
            visible: taskDescription.length > 0
        }
        
        // 任务信息
        RowLayout {
            spacing: 16
            
            // 象限信息
            RowLayout {
                spacing: 4
                
                Text {
                    text: qsTr("象限")
                    font.pixelSize: 12
                    color: "#adb5bd"
                }
                
                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: getQuadrantColor(taskQuadrant)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Q" + taskQuadrant
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: "white"
                    }
                }
            }
            
            // 创建时间
            RowLayout {
                spacing: 4
                
                Text {
                    text: qsTr("创建于")
                    font.pixelSize: 12
                    color: "#adb5bd"
                }
                
                Text {
                    text: formatDate(createdAt)
                    font.pixelSize: 12
                    color: "#adb5bd"
                }
            }
        }
    }
    
    // 获取象限颜色
    function getQuadrantColor(quadrant) {
        switch(quadrant) {
            case 1: return "#ef233c"
            case 2: return "#f72585"
            case 3: return "#4cc9f0"
            default: return "#8d99ae"
        }
    }
    
    // 格式化日期
    function formatDate(dateString) {
        if (!dateString) return ""
        
        const date = new Date(dateString)
        const year = date.getFullYear()
        const month = (date.getMonth() + 1).toString().padStart(2, '0')
        const day = date.getDate().toString().padStart(2, '0')
        const hours = date.getHours().toString().padStart(2, '0')
        const minutes = date.getMinutes().toString().padStart(2, '0')
        
        return `${year}-${month}-${day} ${hours}:${minutes}`
    }
    
    // 数据属性已在组件顶部定义
}