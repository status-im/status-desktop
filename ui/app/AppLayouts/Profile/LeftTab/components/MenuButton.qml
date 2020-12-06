import QtQuick 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../constants.js" as ProfileConstants


Rectangle {
    property int menuItemId: -1
    property bool hovered: false
    property bool active: false
    property url source: "../../../../img/add_watch_only.svg"
    property string text: "My Profile"
    property var onClicked: function () {}

    id: menuButton
    color: hovered || active ? Style.current.secondaryBackground : Style.current.transparent
    border.width: 0
    height: 48
    width: parent.width
    radius: Style.current.radius

    Image {
        id: iconImage
        source: menuButton.source
        height: 24
        width: 24
        sourceSize.width: width
        sourceSize.height: height
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
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
            menuButton.onClicked()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:48;width:300}
}
##^##*/
