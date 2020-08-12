import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "./"

PopupMenu {
    property bool isProfile: false

    id: messageContextMenu
    width: messageContextMenu.isProfile ? profileHeader.width : emojiContainer.width

    Item {
        id: emojiContainer
        visible: !messageContextMenu.isProfile
        width: emojiRow.width
        height: visible ? emojiRow.height : 0

        Row {
            id: emojiRow
            spacing: Style.current.smallPadding
            leftPadding: Style.current.smallPadding
            rightPadding: Style.current.smallPadding
            bottomPadding: Style.current.padding

            Repeater {
                model: reactionModel
                delegate: EmojiReaction {
                    source: "../../../img/" + filename
                    emojiId: model.emojiId
                    closeModal: function () {
                        messageContextMenu.close()
                    }
                }
            }
        }
    }

    Rectangle {
        property bool hovered: false

        id: profileHeader
        visible: messageContextMenu.isProfile
        width: 200
        height: visible ? profileImage.height + username.height + Style.current.padding : 0
        color: hovered ? Style.current.secondaryBackground : Style.current.transparent

        Identicon {
            id: profileImage
            source: profilePopup.identicon
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: username
            text: Utils.removeStatusEns(profilePopup.userName)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            anchors.top: profileImage.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: 15
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                profileHeader.hovered = true
            }
            onExited: {
                profileHeader.hovered = false
            }
            onClicked: {
                profilePopup.open()
            }
        }
    }

    Separator {
        anchors.bottom: viewProfileAction.top
    }

    Action {
        id: viewProfileAction
        //% "View profile"
        text: qsTrId("view-profile")
        onTriggered: profilePopup.open()
        icon.source: "../../../img/profileActive.svg"
        icon.width: 16
        icon.height: 16
    }
    Action {
        text: messageContextMenu.isProfile ?
                  qsTr("Send message") :
                  //% "Reply to"
                  qsTrId("reply-to")
        onTriggered: messageContextMenu.isProfile ? chatsModel.joinChat(profilePopup.fromAuthor, Constants.chatTypeOneToOne) : showReplyArea()
        icon.source: "../../../img/messageActive.svg"
        icon.width: 16
        icon.height: 16
    }
}
