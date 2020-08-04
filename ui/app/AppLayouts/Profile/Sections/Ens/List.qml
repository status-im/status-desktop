import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"

Item {
    property var onClick: function(){}

    StyledText {
        id: sectionTitle
        //% "ENS usernames"
        text: qsTrId("ens-usernames")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Item {
        id: addUsername
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Style.current.bigPadding
        width: addButton.width + usernameText.width + Style.current.padding
        height: addButton.height

        AddButton {
            id: addButton
            clickable: false
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
        }

        StyledText {
            id: usernameText
            text: qsTr("Add username")
            color: Style.current.blue
            anchors.left: addButton.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: addButton.verticalCenter
            font.pixelSize: 15
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: onClick()
        }
    }

    ScrollView {
        id: sview
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: contentItem.childrenRect.height
        anchors.top: addUsername.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Item {
            id: contentItem
            anchors.right: parent.right;
            anchors.left: parent.left;

            StyledText {
                id: title
                text: "TODO: Show ENS username list"
                anchors.top: parent.top
            }
        }
    }
}