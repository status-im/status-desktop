import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"

Rectangle {
    id: walletBtnRoot
    width: btnImage.width + btnImage.anchors.leftMargin + btnImage.anchors.rightMargin +
           btnText.width + btnText.anchors.leftMargin + btnText.anchors.rightMargin
    height: btnText.height + Style.current.smallPadding * 2
    color: Style.current.transparent
    radius: Style.current.radius

    property string text: ""
    property url imageSource
    property bool flipImage: false
    signal clicked()

    SVGImage {
        id: btnImage
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
        id: btnText
        visible: !!walletBtnRoot.text
        text: walletBtnRoot.text
        anchors.left: btnImage.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.rightMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 13
        font.family: Style.current.fontMedium.name
        font.weight: Font.Medium
        color: Style.current.blue
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            parent.color = Style.current.secondaryBackground;
        }
        onExited: {
            parent.color = Style.current.transparent;
        }
        onClicked: {
            walletBtnRoot.clicked();
        }
    }
}
