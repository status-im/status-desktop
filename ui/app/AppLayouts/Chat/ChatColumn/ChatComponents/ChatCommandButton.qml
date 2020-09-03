import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Rectangle {
    property color iconColor
    property string text: "My command"
    property url iconSource: "../../../../img/send.svg"
    property bool rotatedImage: false
    property var onClicked: function () {}

    id: root
    width: 168
    height: 95
    radius: 16
    color: Utils.setColorAlpha(iconColor, 0.2)

    Rectangle {
        id: iconBox
        radius: 50
        color: iconColor
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        height: iconImage.height + Style.current.smallPadding * 2
        width: this.height

        SVGImage {
            id: iconImage
            source: "../../../../img/send.svg"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            fillMode: Image.PreserveAspectFit
            rotation: rotatedImage ? 180 : 0
            antialiasing: true
        }

        ColorOverlay {
            anchors.fill: iconImage
            source: iconImage
            color: Style.current.white
            rotation: rotatedImage ? 180 : 0
            antialiasing: true
        }
    }

    StyledText {
        text: root.text
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        font.weight: Font.Medium
        font.pixelSize: 13
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.onClicked()
        }
    }
}
