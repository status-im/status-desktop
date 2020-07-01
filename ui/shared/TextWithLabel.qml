import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"

Item {
    property string text: "My Text"
    property string label: "My Label"
    property string fontFamily: Theme.fontRegular.name
    readonly property int labelMargin: 7

    id: inputBox
    height: textItem.height + inputLabel.height + labelMargin
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
        color: Theme.darkGrey
    }

    StyledTextEdit {
        id: textItem
        text: inputBox.text
        font.family: fontFamily
        selectByMouse: true
        readOnly: true
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: inputLabel.bottom
        anchors.topMargin: inputBox.labelMargin
        font.pixelSize: 15
        color: Theme.black
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
