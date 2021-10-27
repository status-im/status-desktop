import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import "../controls"
import "./"

// TODO: replace with StatusQ components
Item {
    property string text: "My Text"
    property string label: "My Label"
    property string fontFamily: Style.current.fontRegular.name
    property string textToCopy: ""
    property alias value: textItem
    property bool wrap: false

    id: infoText
    implicitHeight: this.childrenRect.height
    width: parent.width

    StyledText {
        id: inputLabel
        text: infoText.label
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StyledTextEdit {
        id: textItem
        text: infoText.text
        selectByMouse: true
        font.family: fontFamily
        readOnly: true
        anchors.top: inputLabel.bottom
        anchors.topMargin: 4
        font.pixelSize: 15
        wrapMode: infoText.wrap ? Text.WordWrap : Text.NoWrap
        anchors.left: parent.left
        anchors.right: infoText.wrap ? parent.right : undefined
    }

    Loader {
        active: !!infoText.textToCopy
        sourceComponent: copyComponent
        anchors.verticalCenter: textItem.verticalCenter
        anchors.left: textItem.right
        anchors.leftMargin: Style.current.smallPadding
    }

    Component {
        id: copyComponent
        CopyToClipBoardButton {
            textToCopy: infoText.textToCopy
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
