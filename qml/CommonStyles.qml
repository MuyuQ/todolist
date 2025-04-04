pragma Singleton
pragma Singleton
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

QtObject {
    // 对话框样式
    readonly property QtObject dialog: QtObject {
        readonly property int defaultElevation: 24
        readonly property color background: "white"
        readonly property int defaultRadius: 12
        readonly property int defaultPadding: 24
        
        // 标题样式
        readonly property QtObject header: QtObject {
            readonly property int height: 70
            readonly property int padding: 24
            readonly property int fontSize: 22
            readonly property int fontWeight: Font.Medium
        }
        
        // 按钮样式
        readonly property QtObject footer: QtObject {
            readonly property int height: 60
            readonly property int padding: 20
            readonly property int buttonHeight: 40
            readonly property int buttonWidth: 100
            readonly property int fontSize: 14
            readonly property int fontWeight: Font.Medium
        }
        
        // 动画设置
        readonly property QtObject animation: QtObject {
            readonly property int duration: 200
            readonly property int exitDuration: 150
        }
    }
    
    // 输入框样式
    readonly property QtObject input: QtObject {
        readonly property int titleFontSize: 14
        readonly property int titleFontWeight: Font.Medium
        readonly property int fieldFontSize: 16
        readonly property int fieldHeight: 56
        readonly property int fieldRadius: 8
        readonly property color fieldBackground: "#f5f5f5"
        readonly property color borderNormal: "#e0e0e0"
        readonly property int borderWidthNormal: 1
        readonly property int borderWidthFocus: 2
        readonly property int fieldPadding: 16
    }
    
    // 列表项样式
    readonly property QtObject listItem: QtObject {
        readonly property int height: 80
        readonly property int radius: 12
        readonly property int spacing: 8
        readonly property int padding: 8
        readonly property int titleFontSize: 14
        readonly property int descFontSize: 12
        readonly property color descColor: "#666666"
    }
    
    // 面板样式
    readonly property QtObject panel: QtObject {
        readonly property int radius: 12
        readonly property int margin: 10
        readonly property int spacing: 10
        readonly property int headerHeight: 40
        readonly property int headerFontSize: 16
    }
    
    // 通用动画设置
    readonly property QtObject animation: QtObject {
        readonly property int fast: 150
        readonly property int normal: 200
        readonly property int slow: 300
    }
    
    // 通用分隔线
    readonly property QtObject divider: QtObject {
        readonly property int height: 1
        readonly property color color: "#e0e0e0"
    }
    
    // 通用颜色
    readonly property QtObject colors: QtObject {
        readonly property color background: "#fafafa"
        readonly property color cardBackground: "white"
        readonly property color primaryText: "#212121"
        readonly property color secondaryText: "#757575"
        readonly property color divider: "#e0e0e0"
        readonly property color accent: Material.accent
        readonly property color primary: Material.primary
    }
    
    // 通用间距
    readonly property QtObject spacing: QtObject {
        readonly property int xxs: 2
        readonly property int xs: 4
        readonly property int s: 8
        readonly property int m: 12
        readonly property int l: 16
        readonly property int xl: 24
        readonly property int xxl: 32
    }
}