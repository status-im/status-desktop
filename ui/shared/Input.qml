import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Item {
    property alias textField: inputValue
    property string placeholderText: "My placeholder"
    property alias text: inputValue.text
    property string validationError: ""
    property string label: ""
    //    property string label: "My Label"
    readonly property bool hasLabel: label !== ""
    property color bgColor: Theme.grey
    //    property url icon: "../app/img/hash.svg"
    property url icon: ""
    property int iconHeight: 24
    property int iconWidth: 24

    readonly property bool hasIcon: icon.toString() !== ""
    readonly property var forceActiveFocus: function () {
        inputValue.forceActiveFocus(Qt.MouseFocusReason)
    }
    readonly property int labelMargin: 7
    property int customHeight: 44
    property int fontPixelSize: 15

    id: inputBox
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0) + (!!validationError ? validationErrorText.height : 0)
    anchors.right: parent.right
    anchors.left: parent.left

    StyledText {
        id: inputLabel
        text: inputBox.label
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 13
        color: Theme.black
    }

    Rectangle {
        id: inputRectangle
        height: customHeight
        color: bgColor
        radius: 8
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left
        border.width: !!validationError ? 1 : 0
        border.color: Theme.red

        StyledTextField {
            id: inputValue
            visible: !inputBox.isTextArea && !inputBox.isSelect
            placeholderText: inputBox.placeholderText
            text: inputBox.text
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: parent.rightMargin
            anchors.left: parent.left
            anchors.leftMargin: 0
            leftPadding: inputBox.hasIcon ? iconWidth + 20 : Theme.padding
            selectByMouse: true
            font.pixelSize: fontPixelSize
            background: Rectangle {
                color: "#00000000"
            }
        }

        SVGImage {
            id: iconImg
            sourceSize.height: iconHeight
            sourceSize.width: iconWidth
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: inputBox.icon
        }
    }

    TextEdit {
        visible: !!validationError
        id: validationErrorText
        text: validationError
        anchors.top: inputRectangle.bottom
        anchors.topMargin: 1
        selectByMouse: true
        readOnly: true
        font.pixelSize: 12
        color: Theme.red

    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#c0c0c0";formeditorZoom:1.25}
}
##^##*/
