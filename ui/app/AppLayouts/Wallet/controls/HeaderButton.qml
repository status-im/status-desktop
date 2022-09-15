import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0


Rectangle {
    id: headerButton

    property string text: ""
    property url imageSource
    property bool flipImage: false
    property var onClicked: function () {}
    property int margin: 8

    width: buttonImage.width + buttonText.width + Style.current.smallPadding * 2
           + (text === "" ? 0 : headerButton.margin)
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

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.current.primary
        }
    }

    StyledText {
        id: buttonText
        visible: !!headerButton.text
        text: headerButton.text
        anchors.left: buttonImage.right
        anchors.leftMargin: headerButton.margin
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 13
        font.family: Style.current.baseFont.name
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
