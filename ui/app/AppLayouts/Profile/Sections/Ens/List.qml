import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"
import "../../../Chat/ChatColumn/MessageComponents"

Item {
    property var onClick: function(){}

    // Defaults to show message
    property bool isMessage: true
    property bool isEmoji: false
    property bool isCurrentUser: false
    property int contentType: 1
    property string message: qsTr("Hey")
    property string authorCurrentMsg: "0"
    property string authorPrevMsg: "1"
    property var clickMessage: function(){}
    property string identicon: profileModel.profile.identicon
    property int timestamp: 1577872140

    Component {
        id: statusENS
        Item {
            Text {
                id: usernameTxt
                text: username.substr(0, username.indexOf("."))
                color: Style.current.textColor
            }

            Text {

                anchors.top: usernameTxt.bottom
                anchors.topMargin: 2
                text: username.substr(username.indexOf("."))
                color: Style.current.darkGrey
            }
        }
    }

    Component {
        id: normalENS
        Item {
            Text {
                id: usernameTxt
                text: username
                font.pixelSize: 16
                color: Style.current.textColor
                anchors.top: parent.top
                anchors.topMargin: 5
            }
        }
    }

    Component {
        id: ensDelegate
        Item {
            height: 45

            Rectangle {
                id: circle
                width: 35
                height: 35
                radius: 35
                color: Style.current.blue

                StyledText {
                    text: "@"
                    opacity: 0.7
                    font.weight: Font.Bold
                    font.pixelSize: 16
                    color: Style.current.white
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                Loader {
                    sourceComponent: model.username.endsWith(".stateofus.eth") ? statusENS : normalENS
                    property string username: model.username
                    active: true
                    anchors.left: circle.right
                    anchors.leftMargin: Style.current.smallPadding
                }
            }
            
           
            
        }
    }

    ENSPopup {
        id: ensPopup
    }

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


    StyledText {
        id: usernamesLabel
        text: qsTr("Your usernames")
        anchors.left: parent.left
        anchors.top: addUsername.bottom
        anchors.topMargin: 24
        font.pixelSize: 16
    }

    Item {
        anchors.top: usernamesLabel.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        height: 200
        id: ensList

        ScrollView {
            anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: lvEns.contentHeight > lvEns.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            ListView {
                id: lvEns
                anchors.fill: parent
                model: profileModel.ens
                spacing: 10
                clip: true
                delegate: ensDelegate
            }
        }
    }

    Separator {
        id: separator
        anchors.topMargin: Style.current.padding
        anchors.top: ensList.bottom
    }

    StyledText {
        id: chatSettingsLabel
        visible: profileModel.ens.rowCount() > 1
        text: qsTr("Chat Settings")
        anchors.left: parent.left
        anchors.top: ensList.bottom
        anchors.topMargin: 24
        font.pixelSize: 16
    }

    Item {
        width: childrenRect.width
        height: childrenRect.height

        id: preferredUsername
        anchors.left: parent.left
        anchors.top: chatSettingsLabel.bottom
        anchors.topMargin: 24

        StyledText {
            id: usernameLabel
            visible: chatSettingsLabel.visible
            text: qsTr("Primary Username")
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        StyledText {
            id: usernameLabel2
            visible: chatSettingsLabel.visible
            text: profileModel.ens.preferredUsername
            anchors.left: usernameLabel.right
            anchors.leftMargin: Style.current.padding
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log("OPEN")
                ensPopup.open()
            }
        }
    }

    Item {
        anchors.top: profileModel.ens.rowCount() == 1 ? separator.bottom : preferredUsername.bottom
        anchors.topMargin: Style.current.padding * 2

        UserImage {
            id: chatImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: 20
        }

        UsernameLabel {
            id: chatName
            text: profileModel.ens.preferredUsername
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: chatImage.right
        }

        Rectangle {
            property int chatVerticalPadding: 7
            property int chatHorizontalPadding: 12
            id: chatBox
            color: Style.current.secondaryBackground
            height: 35
            width:  80
            radius: 16
            anchors.left: chatImage.right
            anchors.leftMargin: 8
            anchors.top: chatImage.top

            ChatText {
                id: chatText
                anchors.top: parent.top
                anchors.topMargin: chatBox.chatVerticalPadding
                anchors.left: parent.left
                anchors.leftMargin: chatBox.chatHorizontalPadding
                horizontalAlignment: Text.AlignLeft
                color: Style.current.textColor
            }

            RectangleCorner {}
        }

        ChatTime {
            id: chatTime
            anchors.top: chatBox.bottom
            anchors.topMargin: 4
            anchors.bottomMargin: Style.current.padding
            anchors.right: chatBox.right
            anchors.rightMargin: Style.current.padding
        }
    }


}