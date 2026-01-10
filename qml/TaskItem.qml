import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Rectangle {
    id: taskItem

    // QAbstractListModel角色数据在QML delegate中直接可用
    // 在QML中，对于QAbstractListModel的delegate，模型数据直接作为属性访问
    // id、title、description等属性将自动从模型的角色数据中获取值
    property string title: ""
    property string description: ""
    property int quadrant: 1
    property bool isCompleted: false
    property color quadrantColor: "#6750a4"

    // 动画属性
    property real animationProgress: 0

    onIsCompletedChanged: {
        if (isCompleted) {
            strikeAnimation.start()
            progressAnimation.start()
        } else {
            animationProgress = 0
        }
    }

    NumberAnimation {
        id: progressAnimation
        target: taskItem
        property: "animationProgress"
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutQuad
    }
    
    // 调试信息
    Component.onCompleted: {
        console.log("TaskItem创建 - 标题:", title, "从四象限:", quadrant, "是否完成:", isCompleted)
    }
    
    onTitleChanged: {
        console.log("TaskItem标题变化 - 新标题:", title)
    }
    
    // 设置最小高度以确保足够的显示空间
    implicitHeight: contentLayout.implicitHeight + 24
    color: "white"

    // 淡入动画
    opacity: 0
    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: 300
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: {
        opacity = 1
    }
    
    // 拖放相关属性
    property bool dragActive: false
    property point dragStart
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        // 确保列布局不会溢出父容器
        Layout.fillWidth: true
        
        RowLayout {
            spacing: 8
            
            // 完成复选框
            Rectangle {
                id: checkbox
                width: 20
                height: 20
                radius: 10
                border.width: 2
                border.color: quadrantColor
                color: isCompleted ? quadrantColor : "white"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 控制器返回字典数组，任务ID在model.modelData.id中
                        taskController.setTaskCompleted(model.modelData.id, !isCompleted)
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 12
                    color: "white"
                    visible: isCompleted
                }
            }
            
            // 任务标题
            Item {
                Layout.fillWidth: true
                height: titleText.implicitHeight

                Text {
                    id: titleText
                    text: title || "(无标题任务)"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    // 使用更明显的颜色确保文本可见
                    color: isCompleted ? "#79747e" : "#1d1b20"
                    elide: Text.ElideRight
                    anchors.fill: parent

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // 控制器返回字典数组，任务ID在model.modelData.id中
                            editTaskDialog.open(model.modelData.id, title, description, quadrant)
                        }
                    }
                }

                // 完成划线动画
                Shape {
                    id: strikeThrough
                    anchors.fill: titleText
                    visible: isCompleted

                    ShapePath {
                        strokeColor: "#79747e"
                        strokeWidth: 2
                        startX: 0
                        startY: titleText.height / 2
                        PathLine {
                            x: strikeThrough.width * animationProgress
                            y: titleText.height / 2
                        }
                    }

                    NumberAnimation on opacity {
                        id: strikeAnimation
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
        
        // 任务描述
        Text {
            text: description
            font.pixelSize: 14
            color: "#8d99ae"
            elide: Text.ElideRight
            Layout.fillWidth: true
            visible: description.length > 0
        }
        
        // 操作按钮区域
        RowLayout {
            spacing: 8
            
            Item { Layout.fillWidth: true }
            
            // 移动按钮
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "#f8f9fa"
                
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        dragActive = true
                        dragStart = Qt.point(mouseX, mouseY)
                    }
                    onReleased: {
                        dragActive = false
                    }
                    onPositionChanged: {
                        if (dragActive) {
                            // 这里可以实现拖动功能
                        }
                    }
                    cursorShape: Qt.OpenHandCursor
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "⋮⋮"
                    font.pixelSize: 12
                    color: "#8d99ae"
                }
            }
            
            // 编辑按钮
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "#f8f9fa"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 控制器返回字典数组，任务ID在model.modelData.id中
                        editTaskDialog.open(model.modelData.id, title, description, quadrant)
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✎"
                    font.pixelSize: 12
                    color: "#8d99ae"
                }
            }
        }
    }
    
    // 悬停效果
    MouseArea {
        // 不覆盖子元素，启用鼠标事件传递
        anchors.fill: parent
        hoverEnabled: true
        // 避免事件冲突，不处理点击事件
        propagateComposedEvents: true
        
        onEntered: {
            taskItem.color = "#e7e0ec"
        }
        onExited: {
            taskItem.color = "#fffbfe"
        }
        // 只处理鼠标悬停，不处理点击
        onClicked: {
            // 不阻止事件传播给子元素
            mouse.accepted = false
        }
    }
    
    // 数据属性已在组件顶部定义
}