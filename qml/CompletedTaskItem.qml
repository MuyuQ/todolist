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
    
    // 现代化卡片设计
    implicitHeight: contentLayout.implicitHeight + 32
    width: parent ? parent.width : 400
    
    // 现代化圆角和颜色
    radius: 16
    color: "#ffffff"
    
    // 模拟阴影效果（使用边框颜色）
    border.width: 1
    border.color: "#e5e7eb"
    
    // 背景渐变效果
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#ffffff" }
        GradientStop { position: 1.0; color: "#fafbfc" }
    }
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        
        // 顶部区域：标题和完成状态
        RowLayout {
            spacing: 12
            
            // 现代化完成标记
            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: "#22c55e"  // 绿色完成标记
                border.width: 2
                border.color: "#16a34a"
                
                // 完成图标
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "white"
                }
            }
            
            // 现代化任务标题
            Text {
                text: taskTitle
                font.pixelSize: 18
                font.weight: Font.Medium
                color: "#374151"  // 深灰蓝色
                elide: Text.ElideRight
                Layout.fillWidth: true
                
                // 现代化字体渲染
                renderType: Text.NativeRendering
            }
        }
        
        // 任务描述（现代化样式）
        Text {
            text: taskDescription
            font.pixelSize: 15
            color: "#6b7280"  // 中性灰
            elide: Text.ElideRight
            Layout.fillWidth: true
            visible: taskDescription.length > 0
            lineHeight: 1.4  // 增加行高，提升可读性
            wrapMode: Text.WordWrap
        }
        
        // 底部信息栏（现代化设计）
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#f3f4f6"  // 浅灰色分割线
            visible: true
        }
        
        RowLayout {
            spacing: 20
            
            // 象限标签（现代化设计）
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 24
                radius: 12
                color: getQuadrantColor(taskQuadrant)
                
                // 象限图标
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#4dffffff"
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "Q" + taskQuadrant
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "white"
                }
                
                // 象限标签的轻微阴影（使用边框模拟）
                border.width: 1
                border.color: "#1a000000"
            }
            
            Item { Layout.fillWidth: true } // 弹性空间
            
            // 现代化时间标签（修复对齐问题）
            Rectangle {
                Layout.preferredWidth: 120  // 设置固定宽度防止超出
                Layout.preferredHeight: 24
                radius: 12
                color: "#f9fafb"
                border.width: 1
                border.color: "#e5e7eb"
                
                Text {
                    anchors.centerIn: parent
                    text: formatDate(createdAt)
                    font.pixelSize: 12
                    color: "#6b7280"
                    elide: Text.ElideRight  // 文本过长时截断
                    horizontalAlignment: Text.AlignHCenter  // 水平居中对齐
                    Layout.fillWidth: false
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