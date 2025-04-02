import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
// 已移除不需要的导入

Dialog {
    id: baseDialog
    modal: true
    anchors.centerIn: parent
    width: 520
    height: 480
    padding: CommonStyles.dialog.defaultPadding
    
    // Material设计风格
    Material.elevation: CommonStyles.dialog.defaultElevation
    Material.background: CommonStyles.dialog.background
    
    // 圆角边框
    background: Rectangle {
        id: dialogBackground
        color: "white"
        radius: CommonStyles.dialog.defaultRadius
        border.width: 1
        border.color: CommonStyles.input.borderNormal
    }
    
    // 使用统一的阴影效果组件
    ShadowEffect {
        id: dialogShadow
        offsetY: 4
        blurRadius: 12.0
        samples: 16
        shadowColor: "#30000000"
        Component.onCompleted: applyTo(dialogBackground)
    }
    
    // 对话框标题样式
    header: Item {
        width: parent.width
        height: CommonStyles.dialog.header.height
        
        Pane {
            anchors.fill: parent
            anchors.bottomMargin: 1
            padding: CommonStyles.dialog.header.padding
            Material.elevation: 0
            Material.background: "transparent"
            
            Label {
                text: baseDialog.title
                font.pixelSize: CommonStyles.dialog.header.fontSize
                font.weight: CommonStyles.dialog.header.fontWeight
                color: Material.primary
            }
        }
        
        // 添加底部分隔线
        Rectangle {
            width: parent.width
            height: CommonStyles.divider.height
            color: CommonStyles.divider.color
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }
    
    // 对话框按钮样式
    footer: Item {
        width: parent.width
        height: CommonStyles.dialog.footer.height
        
        // 添加顶部分隔线
        Rectangle {
            width: parent.width
            height: CommonStyles.divider.height
            color: CommonStyles.divider.color
            anchors.top: parent.top
            anchors.left: parent.left
        }
        
        DialogButtonBox {
            id: buttonBox
            anchors.fill: parent
            anchors.topMargin: 1
            standardButtons: baseDialog.standardButtons
            padding: CommonStyles.dialog.footer.padding
            alignment: Qt.AlignRight
            Material.background: "transparent"
            Material.elevation: 0
            
            onAccepted: baseDialog.accept()
            onRejected: baseDialog.reject()
            
            // 自定义按钮样式
            delegate: Button {
                flat: true
                highlighted: DialogButtonBox.buttonRole === DialogButtonBox.AcceptRole
                Material.accent: Material.primary
                font.pixelSize: CommonStyles.dialog.footer.fontSize
                font.weight: CommonStyles.dialog.footer.fontWeight
                implicitHeight: CommonStyles.dialog.footer.buttonHeight
                implicitWidth: CommonStyles.dialog.footer.buttonWidth
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    opacity: enabled ? 1.0 : 0.3
                    color: parent.highlighted ? Material.accent : Material.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }

    // 添加打开和关闭动画
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: CommonStyles.dialog.animation.duration }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: CommonStyles.dialog.animation.duration }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: CommonStyles.dialog.animation.exitDuration }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: CommonStyles.dialog.animation.exitDuration }
    }
}