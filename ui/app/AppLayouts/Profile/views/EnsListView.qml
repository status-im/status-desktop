import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "../popups"
import shared 1.0
import shared.panels 1.0
import shared.views.chat 1.0
import shared.panels.chat 1.0
import shared.controls.chat 1.0

Item {
    id: root
    signal addBtnClicked()
    signal selectEns(string username)

    property var store

    // Defaults to show message
    property bool isMessage: true
    property bool isEmoji: false
    property bool isCurrentUser: false
    property int contentType: 1
    //% "Hey"
    property string message: qsTrId("ens-test-message")
    property string authorCurrentMsg: "0"
    property string authorPrevMsg: "1"
    property bool isText: true
    property var clickMessage: function(){}
    property string identicon: store.identicon
    //property string identicon: userProfile.thumbnailImage
    property int timestamp: 1577872140
    property var messageStore

    function shouldDisplayExampleMessage(){
        return store.ens.rowCount() > 0 && store.ensPendingLen() !== store.ens.rowCount() && store.preferredUsername !== ""
    }
    anchors.fill: parent

    Item {
        anchors.top: parent.top
        width: profileContainer.profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter

        Component {
            id: statusENS
            Item {
                Text {
                    id: usernameTxt
                    //% "(pending)"
                    text: username.substr(0, username.indexOf(".")) + " " + (isPending ? qsTrId("-pending-") : "")
                    color: Style.current.textColor
                }

                Text {

                    anchors.top: usernameTxt.bottom
                    anchors.topMargin: 2
                    text: username.substr(username.indexOf("."))
                    color: Theme.palette.baseColor1
                }
            }
        }

        Component {
            id: normalENS
            Item {
                Text {
                    id: usernameTxt
                    //% "(pending)"
                    text: username  + " " + (isPending ? qsTrId("-pending-") : "")
                    font.pixelSize: 16
                    color: Theme.palette.directColor1
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }
            }
        }

        Component {
            id: ensDelegate
            Item {
                height: 45
                anchors.left: parent.left
                anchors.right: parent.right

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: selectEns(model.username)
                }

                Rectangle {
                    id: circle
                    width: 35
                    height: 35
                    radius: 35
                    color: Theme.palette.primaryColor1

                    StatusBaseText {
                        text: "@"
                        opacity: 0.7
                        font.weight: Font.Bold
                        font.pixelSize: 16
                        color: Theme.palette.indirectColor1
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Loader {
                    sourceComponent: model.username.endsWith(".stateofus.eth") ? statusENS : normalENS
                    property string username: model.username
                    property bool isPending: model.isPending
                    active: true
                    anchors.left: circle.right
                    anchors.leftMargin: Style.current.smallPadding
                }
            }
        }

        ENSPopup {
            id: ensPopup
        }

        StatusBaseText {
            id: sectionTitle
            //% "ENS usernames"
            text: qsTrId("ens-usernames")
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: parent.top
            anchors.topMargin: 24
            font.weight: Font.Bold
            font.pixelSize: 20
            color: Theme.palette.directColor1
        }

        Item {
            id: addUsername
            anchors.top: sectionTitle.bottom
            anchors.topMargin: Style.current.bigPadding
            width: addButton.width + usernameText.width + Style.current.padding
            height: addButton.height

            StatusRoundButton {
                id: addButton
                width: 40
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "add"
                type: StatusRoundButton.Type.Secondary
            }

            StatusBaseText {
                id: usernameText
                //% "Add username"
                text: qsTrId("ens-add-username")
                color: Theme.palette.primaryColor1
                anchors.left: addButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: addButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: addBtnClicked()
            }
        }


        StatusBaseText {
            id: usernamesLabel
            //% "Your usernames"
            text: qsTrId("ens-your-usernames")
            anchors.left: parent.left
            anchors.top: addUsername.bottom
            anchors.topMargin: 24
            font.pixelSize: 16
            color: Theme.palette.directColor1
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
                    model: root.store.ens
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

        StatusBaseText {
            id: chatSettingsLabel
            visible: root.store.ens.rowCount() > 0 && root.store.ensPendingLen() != root.store.ens.rowCount()
            //% "Chat settings"
            text: qsTrId("chat-settings")
            anchors.left: parent.left
            anchors.top: ensList.bottom
            anchors.topMargin: 24
            font.pixelSize: 16
            color: Theme.palette.directColor1
        }

        Item {
            width: childrenRect.width
            height: childrenRect.height

            id: preferredUsername
            anchors.left: parent.left
            anchors.top: chatSettingsLabel.bottom
            anchors.topMargin: 24

            StatusBaseText {
                id: usernameLabel
                visible: chatSettingsLabel.visible
                //% "Primary Username"
                text: qsTrId("primary-username")
                font.pixelSize: 14
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: usernameLabel2
                visible: chatSettingsLabel.visible
                //% "None selected"
                text: root.store.preferredUsername || qsTrId("none-selected")
                anchors.left: usernameLabel.right
                anchors.leftMargin: Style.current.padding
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ensPopup.open()
            }
        }

        Item {
            id: messagesShownAs
            visible: shouldDisplayExampleMessage()
            anchors.top: !visible ? separator.bottom : preferredUsername.bottom
            anchors.topMargin: Style.current.padding * 2

            UserImage {
                id: chatImage
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.top: parent.top
                anchors.topMargin: 20
//                isCurrentUser: root.isCurrentUser
//                profileImage: root.messageStore.profileImageSource
//                isMessage: root.messageStore.isMessage
//                identiconImageSource: root.messageStore.identicon
                onClickMessage: {
                    root.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
                }
            }

            UsernameLabel {
                id: chatName
                label.text: "@" + (root.store.preferredUsername.replace(".stateofus.eth", ""))
                label.color: Style.current.blue
                anchors.leftMargin: 20
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: chatImage.right
//                isCurrentUser: root.messageStore.isCurrentUser
//                userName: root.messageStore.userName
//                localName: root.messageStore.localName
//                displayUserName: root.messageStore.displayUserName
                onClickMessage: {
                    root.parent.clickMessage(true, false, false, null, false, false, false);
                }
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

                ChatTextView {
                    id: chatText
                    anchors.top: parent.top
                    anchors.topMargin: chatBox.chatVerticalPadding
                    anchors.left: parent.left
                    anchors.leftMargin: chatBox.chatHorizontalPadding
                    width: parent.width
                    anchors.right: parent.right
                    store: root.store
                    messageStore: root.messageStore
                }

                RectangleCorner {}
            }

            ChatTimePanel {
                id: chatTime
                anchors.top: chatBox.bottom
                anchors.topMargin: 4
                anchors.bottomMargin: Style.current.padding
                anchors.right: chatBox.right
                anchors.rightMargin: Style.current.padding
                //timestamp: root.timestamp
                visible: root.messageStore.isMessage
            }

            StatusBaseText {
                anchors.top: chatTime.bottom
                anchors.left: chatImage.left
                anchors.topMargin: Style.current.padding
                //% "You’re displaying your ENS username in chats"
                text: qsTrId("you-re-displaying-your-ens-username-in-chats")
                font.pixelSize: 14
                color: Theme.palette.baseColor1
            }
        }


        Connections {
            target: root.store.ens
            onPreferredUsernameChanged: {
                messagesShownAs.visible = shouldDisplayExampleMessage()
            }
            onUsernameConfirmed: {
                messagesShownAs.visible = shouldDisplayExampleMessage()
                chatSettingsLabel.visible = true
            }
        }
    }
}

