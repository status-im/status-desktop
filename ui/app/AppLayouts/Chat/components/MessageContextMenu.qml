import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

PopupMenu {
    property bool isProfile: false
    property bool isSticker: false
    property bool emojiOnly: false
    property string linkUrls: ""
    property alias emojiContainer: emojiContainer

    id: messageContextMenu
    width: messageContextMenu.isProfile ? profileHeader.width : emojiContainer.width

    property var identicon: ""
    property var userName: ""
    property string nickname: ""
    property var fromAuthor: ""
    property var text: ""
    property var emojiReactionsReactedByUser: []
    subMenuIcons: [
        {
            source: Qt.resolvedUrl("../../../../shared/img/copy-to-clipboard-icon"),
            width: 16,
            height: 16
        }
    ]

    function show(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, emojiReactionsModel) {
        userName = userNameParam || ""
        nickname = nicknameParam || ""
        fromAuthor = fromAuthorParam || ""
        identicon = identiconParam || ""
        text = textParam || ""
        let newEmojiReactions = []
        if (!!emojiReactionsModel) {
            emojiReactionsModel.forEach(function (emojiReaction) {
                newEmojiReactions[emojiReaction.emojiId] = emojiReaction.currentUserReacted
            })
        }
        emojiReactionsReactedByUser = newEmojiReactions

        const numLinkUrls = messageContextMenu.linkUrls.split(" ").length
        copyLinkMenu.enabled = numLinkUrls > 1
        copyLinkAction.enabled = !!messageContextMenu.linkUrls && numLinkUrls === 1 && !emojiOnly && !messageContextMenu.isProfile
        popup();
    }

    Item {
        id: emojiContainer
        visible: messageContextMenu.emojiOnly || !messageContextMenu.isProfile
        width: emojiRow.width
        height: visible ? emojiRow.height : 0

        Row {
            id: emojiRow
            spacing: Style.current.smallPadding
            leftPadding: Style.current.smallPadding
            rightPadding: Style.current.smallPadding
            bottomPadding: messageContextMenu.emojiOnly ? 0 : Style.current.padding

            Repeater {
                model: reactionModel
                delegate: EmojiReaction {
                    source: "../../../img/" + filename
                    emojiId: model.emojiId
                    reactedByUser: !!messageContextMenu.emojiReactionsReactedByUser[model.emojiId]
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

        StatusImageIdenticon {
            id: profileImage
            source: identicon
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: username
            text: Utils.removeStatusEns(userName)
            elide: Text.ElideRight
            maximumLineCount: 3
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
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
                openProfilePopup(userName, fromAuthor, identicon);
                messageContextMenu.close()
            }
        }
    }

    Separator {
        anchors.bottom: viewProfileAction.top
        visible: !messageContextMenu.emojiOnly
    }

    Action {
        id: copyLinkAction
        text: qsTr("Copy link")
        onTriggered: {
            chatsModel.copyToClipboard(linkUrls.split(" ")[0])
            messageContextMenu.close()
        }
        icon.source: "../../../../shared/img/copy-to-clipboard-icon"
        icon.width: 16
        icon.height: 16
        enabled: false
    }

    PopupMenu {
        id: copyLinkMenu
        title: qsTr("Copy link")
        Repeater {
            id: linksRepeater
            model: messageContextMenu.linkUrls.split(" ")
            delegate: MenuItem {
                text: modelData
                onTriggered: {
                    chatsModel.copyToClipboard(modelData)
                    messageContextMenu.close()
                }
            }
        }
    }

    Action {
        id: viewProfileAction
        //% "View Profile"
        text: qsTrId("view-profile")
        onTriggered: {
            openProfilePopup(userName, fromAuthor, identicon, "", nickname);
            messageContextMenu.close()
        }
        icon.source: "../../../img/profileActive.svg"
        icon.width: 16
        icon.height: 16
        enabled: !emojiOnly && !copyLinkAction.enabled
    }
    Action {
        text: messageContextMenu.isProfile ?
                  //% "Send message"
                  qsTrId("send-message") :
                  //% "Reply to"
                  qsTrId("reply-to")
        onTriggered: {
            if (messageContextMenu.isProfile) {
                appMain.changeAppSection(Constants.chat)
                chatsModel.joinChat(fromAuthor, Constants.chatTypeOneToOne)
            } else {
              showReplyArea()
            }
            messageContextMenu.close()
        }
        icon.source: "../../../img/messageActive.svg"
        icon.width: 16
        icon.height: 16
        enabled: !isSticker && !emojiOnly
    }
}
