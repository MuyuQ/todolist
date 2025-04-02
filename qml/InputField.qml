import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ColumnLayout {
    id: root
    spacing: 8
    Layout.fillWidth: true
    
    property string label: ""
    property string placeholderText: ""
    property string text: ""
    property bool isTextArea: false
    property int preferredHeight: isTextArea ? 120 : CommonStyles.input.fieldHeight
    property bool fillHeight: isTextArea
    property alias field: fieldLoader.item
    
    signal textEdited(string text)
    
    // 当外部text属性变化时，更新内部field的text
    onTextChanged: {
        if (fieldLoader.item && fieldLoader.item.text !== text) {
            fieldLoader.item.text = text
        }
    }
    
    // 标签
    Label {
        text: label
        font.pixelSize: CommonStyles.input.titleFontSize
        font.weight: CommonStyles.input.titleFontWeight
        color: Material.foreground
        visible: label !== ""
    }
    
    // 使用Loader动态加载TextField或TextArea
    Loader {
        id: fieldLoader
        Layout.fillWidth: true
        Layout.fillHeight: root.fillHeight
        Layout.preferredHeight: root.preferredHeight
        sourceComponent: root.isTextArea ? textAreaComponent : textFieldComponent
    }
    
    // TextField组件
    Component {
        id: textFieldComponent
        
        TextField {
            id: field
            text: root.text
            placeholderText: root.placeholderText
            selectByMouse: true
            font.pixelSize: CommonStyles.input.fieldFontSize
            leftPadding: CommonStyles.input.fieldPadding
            rightPadding: CommonStyles.input.fieldPadding
            topPadding: 8
            bottomPadding: 8
            onTextChanged: {
                if (text !== root.text) {
                    root.text = text
                    root.textEdited(text)
                }
            }
            
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: CommonStyles.input.fieldHeight
                color: CommonStyles.input.fieldBackground
                border.color: field.activeFocus ? Material.accent : CommonStyles.input.borderNormal
                border.width: field.activeFocus ? CommonStyles.input.borderWidthFocus : CommonStyles.input.borderWidthNormal
                radius: CommonStyles.input.fieldRadius
            }
        }
    }
    
    // TextArea组件
    Component {
        id: textAreaComponent
        
        ScrollView {
            clip: true
            
            TextArea {
                id: field
                text: root.text
                placeholderText: root.placeholderText
                wrapMode: Text.WordWrap
                selectByMouse: true
                font.pixelSize: CommonStyles.input.fieldFontSize - 2 // 稍微小一点
                leftPadding: CommonStyles.input.fieldPadding
                rightPadding: CommonStyles.input.fieldPadding
                topPadding: 12
                bottomPadding: 12
                onTextChanged: {
                    if (text !== root.text) {
                        root.text = text
                        root.textEdited(text)
                    }
                }
                
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 120
                    color: CommonStyles.input.fieldBackground
                    border.color: field.activeFocus ? Material.accent : CommonStyles.input.borderNormal
                    border.width: field.activeFocus ? CommonStyles.input.borderWidthFocus : CommonStyles.input.borderWidthNormal
                    radius: CommonStyles.input.fieldRadius
                }
            }
        }
    }
    
    // 公共方法
    function forceActiveFocus() {
        fieldLoader.item.forceActiveFocus()
    }
    
    function selectAll() {
        if (fieldLoader.item.selectAll) {
            fieldLoader.item.selectAll()
        }
    }
}