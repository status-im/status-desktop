import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"

Item {
    property string text: "My Text"
    property string label: "My Label"
    property string fontFamily: Style.current.fontRegular.name
    property string textToCopy: ""

    id: infoText
    height: this.childrenRect.height
    width: parent.width

    StyledText {
        id: inputLabel
        text: infoText.label
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.grey
    }

    StyledTextEdit {
        id: textItem
        text: infoText.text
        font.family: fontFamily
        selectByMouse: true
        readOnly: true
        anchors.top: inputLabel.bottom
        anchors.topMargin: 7
        font.pixelSize: 15
    }

    CopyToClipBoardButton {
        visible: !!infoText.textToCopy
        anchors.verticalCenter: textItem.verticalCenter
        anchors.left: textItem.right
        anchors.leftMargin: Style.current.smallPadding
        textToCopy: infoText.textToCopy
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
