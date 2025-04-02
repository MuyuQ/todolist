import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    // 阴影属性
    property real offsetX: 0
    property real offsetY: 3
    property real blurRadius: 8.0
    property int samples: 12
    property color shadowColor: "#25000000"
    property bool transparentBorder: true
    property bool animated: false
    property bool isDragging: false
    
    // 应用阴影效果
    function applyTo(target) {
        target.layer.enabled = true
        target.layer.effect = shadowEffect
    }
    
    // 阴影效果组件
    Component {
        id: shadowEffect
        
        DropShadow {
            transparentBorder: root.transparentBorder
            horizontalOffset: root.offsetX
            verticalOffset: root.isDragging && root.animated ? 8 : root.offsetY
            radius: root.isDragging && root.animated ? 12.0 : root.blurRadius
            samples: root.samples
            color: root.isDragging && root.animated ? "#40000000" : root.shadowColor
            
            // 动画效果 - 只在需要时启用
            Behavior on verticalOffset { enabled: root.animated; NumberAnimation { duration: 150 } }
            Behavior on radius { enabled: root.animated; NumberAnimation { duration: 150 } }
            Behavior on color { enabled: root.animated; ColorAnimation { duration: 150 } }
        }
    }
}