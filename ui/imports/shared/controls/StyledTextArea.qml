import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import utils 1.0
import "../panels"

Item {
    property alias textField: textArea
    property string placeholderText: "My placeholder"
    property alias text: textArea.text
    property string validationError: ""
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Style.current.inputBackground
    readonly property var forceActiveFocus: function () {
        textArea.forceActiveFocus(Qt.MouseFocusReason)
    }
    readonly property int labelMargin: 7
    property int customHeight: 44
    property bool hideRectangle: false
    signal keyPressed(var event)

    id: inputBox
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0) + (!!validationError ? validationErrorText.height : 0)

    StyledText {
        id: inputLabel
        text: inputBox.label
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 13
    }

    Rectangle {
        id: inputRectangle
        height: customHeight
        color: hideRectangle ? Style.current.transparent : bgColor
        radius: Style.current.radius
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left
        border.width: !!validationError && !hideRectangle ? 1 : 0
        border.color: Style.current.red

        TextArea {
            id: textArea
            text: ""
            font.pixelSize: 15
            selectByMouse: true
            wrapMode: Text.WrapAnywhere
            placeholderText: inputBox.placeholderText
            anchors.rightMargin: Style.current.smallPadding
            anchors.leftMargin: inputBox.hasIcon ? 36 : Style.current.smallPadding
            anchors.bottomMargin: Style.current.smallPadding
            anchors.topMargin: Style.current.smallPadding
            anchors.fill: parent
            font.family: Style.current.baseFont.name
            color: Style.current.textColor
            placeholderTextColor: Style.current.secondaryText
            selectionColor: Style.current.primarySelectionColor

            Keys.onPressed: inputBox.keyPressed(event)
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
        color: Style.current.red
        selectedTextColor: Style.current.textColor
        selectionColor: Style.current.primarySelectionColor
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/

