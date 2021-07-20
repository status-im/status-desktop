import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../constants.js" as ProfileConstants


Rectangle {
    property int menuItemId: -1
    property bool hovered: false
    property bool active: false
    property url source: "../../../../img/eye.svg"
    property string text: "My Profile"
    signal clicked()

    id: menuButton
    color: {
         if (active) {
            return Style.current.menuBackgroundActive
         }
         if (hovered) {
            return Style.current.menuBackgroundHover
         }
         return Style.current.transparent
    }
    border.width: 0
    height: 48
    width: parent.width
    radius: Style.current.radius

    SVGImage {
        id: iconImage
        height: 24
        width: 24
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        source: menuButton.source

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.current.blue
        }
    }

    StyledText {
        text: menuButton.text
        anchors.left: iconImage.right
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        visible: !profileModel.mnemonic.isBackedUp && !active && ProfileConstants.PRIVACY_AND_SECURITY === menuItemId
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: menuButton.right
        anchors.rightMargin: 10
        radius: 9
        color: Style.current.blue
        width: 18
        height: 18
        Text {
            font.pixelSize: 12
            color: Style.current.white
            anchors.centerIn: parent
            text: "1"
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          menuButton.hovered = true
        }
        onExited: {
          menuButton.hovered = false
        }
        onClicked: function () {
            menuButton.clicked()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:48;width:300}
}
##^##*/
