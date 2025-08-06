import QtQuick
import QtQuick.Effects

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared
import shared.panels

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
        font.weight: Font.Medium
        font.pixelSize: Theme.additionalTextSize
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
