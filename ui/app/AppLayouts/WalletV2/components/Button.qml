import QtQuick 2.14
import QtGraphicalEffects 1.14
import "../../../../imports"
import "../../../../shared"

Rectangle {
    id: btnRoot
    width: (btnText.visible? btnText.width + btnText.anchors.leftMargin + btnText.anchors.rightMargin : 0) +
        (btnImage.visible? btnImage.width + btnImage.anchors.leftMargin + btnImage.anchors.rightMargin : 0)
    height: {
        if(btnText.visible)
            return btnText.height + Style.current.smallPadding * 2
        else if(btnImage.visible)
            return btnImage.height + Style.current.smallPadding

        return 0
    }
    border.width: 0
    color: Style.current.transparent
    radius: Style.current.radius

    property string text: ""
    property color textColor: Style.current.blue
    property url imageSource
    property bool flipImage: false
    property var onClicked: function () {}

    SVGImage {
        id: btnImage
        visible: btnRoot.imageSource.toString() !== ""
        height: 18
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: btnRoot.imageSource
        rotation: btnRoot.flipImage ? 180 : 0

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.current.primary
        }
    }

    StyledText {
        id: btnText
        visible: btnRoot.text !== ""
        text: btnRoot.text
        anchors.left: btnImage.visible? btnImage.right : parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.rightMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 13
        font.family: Style.current.fontMedium.name
        font.weight: Font.Medium
        color: btnRoot.textColor
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
            btnRoot.onClicked()
        }
        cursorShape: Qt.PointingHandCursor
    }
}
