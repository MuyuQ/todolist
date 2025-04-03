pragma Singleton
import QtQuick 2.15

// 统一导入模块，减少重复导入
QtObject {
    // 常用导入路径，可以在其他QML文件中引用
    readonly property string qtQuick: "import QtQuick 2.15"
    readonly property string qtControls: "import QtQuick.Controls 2.15"
    readonly property string qtLayouts: "import QtQuick.Layouts 1.15"
    readonly property string qtMaterial: "import QtQuick.Controls.Material 2.15"
    readonly property string qtWindow: "import QtQuick.Window 2.15"
    
    // 常用导入组合
    readonly property string basicImports: qtQuick + "\n" + qtControls + "\n" + qtLayouts
    readonly property string materialImports: basicImports + "\n" + qtMaterial
    readonly property string fullImports: materialImports + "\n" + qtWindow
}