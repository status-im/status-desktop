import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

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

    width: buttonImage.width + buttonText.width + Theme.smallPadding * 2
           + (text === "" ? 0 : headerButton.margin)
    height: buttonText.height + Theme.smallPadding * 2
    border.width: 0
    color: Theme.palette.transparent
    radius: Theme.radius

    SVGImage {
        id: buttonImage
        height: 18
        anchors.left: parent.left
        anchors.leftMargin: Theme.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: imageSource
        rotation: flipImage ? 180 : 0

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Theme.palette.primaryColor1
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
        font.weight: Font.Medium
        color: Theme.palette.primaryColor1
    }

    StatusMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            parent.color = Theme.palette.secondaryBackground
        }
        onExited: {
            parent.color = Theme.palette.transparent
        }
        onClicked: {
            headerButton.onClicked()
        }
        cursorShape: Qt.PointingHandCursor
    }
}
