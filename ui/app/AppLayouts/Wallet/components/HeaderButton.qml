import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"


Rectangle {
    property string text: ""
    property url imageSource
    property bool flipImage: false
    property var onClicked: function () {}

    id: headerButton
    width: buttonImage.width + buttonText.width + Style.current.smallPadding * 2
           + (text === "" ? 0 : walletMenu.btnMargin)
    height: buttonText.height + Style.current.smallPadding * 2
    border.width: 0
    color: Style.current.transparent
    radius: Style.current.radius

    SVGImage {
        id: buttonImage
        height: 18
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: imageSource
        rotation: flipImage ? 180 : 0
    }

    StyledText {
        id: buttonText
        visible: !!headerButton.text
        text: headerButton.text
        anchors.left: buttonImage.right
        anchors.leftMargin: walletMenu.btnMargin
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 13
        font.family: Style.current.fontMedium.name
        font.weight: Font.Medium
        color: Style.current.blue
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            parent.color = Style.current.secondaryBackground
        }
        onExited: {
            parent.color = Style.current.transparent
        }
        onClicked: {
            headerButton.onClicked()
        }
        cursorShape: Qt.PointingHandCursor
    }
}
