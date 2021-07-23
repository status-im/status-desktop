import QtQuick 2.13
import QtQuick.Controls 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../data"
import "../ChatColumn"

ModalPopup {
    property bool userCanPin: {
        switch (chatsModel.channelView.activeChannel.chatType) {
        case Constants.chatTypePublic: return false
        case Constants.chatTypeStatusUpdate: return false
        case Constants.chatTypeOneToOne: return true
        case Constants.chatTypePrivateGroupChat: return chatsModel.channelView.activeChannel.isAdmin(profileModel.profile.pubKey)
        case Constants.chatTypeCommunity: return chatsModel.communities.activeCommunity.admin
        default: return false
        }
    }
    property string messageToPin
    property string messageToUnpin

    id: popup

    header: Item {
        height: childrenRect.height
        width: parent.width

        StyledText {
            id: title
            text: !!messageToPin ? qsTr("Pin limit reached") :
                                               //% "Pinned messages"
                                               qsTrId("pinned-messages")
            anchors.top: parent.top
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: 17
        }

        StyledText {
            property int nbMessages: pinnedMessageListView.count

            id: nbPinnedMessages
            text: {
                if (!!messageToPin) {
                    return qsTr("Unpin a previous message first")
                }

                //% "%1 messages"
                return nbMessages > 1 ? qsTrId("-1-messages").arg(nbMessages) :
                                        //% "%1 message"
                                        qsTrId("-1-message").arg(nbMessages)
            }
            anchors.left: parent.left
            anchors.top: title.bottom
            anchors.topMargin: 2
            font.pixelSize: 15
            color: Style.current.secondaryText
        }

        Separator {
            anchors.top: nbPinnedMessages.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }
    }

    Item {
        anchors.fill: parent

        StyledText {
            visible: pinnedMessageListView.count === 0
            //% "Pinned messages will appear here."
            text: qsTrId("pinned-messages-will-appear-here-")
            anchors.centerIn: parent
            color: Style.current.secondaryText
        }

        ButtonGroup {
            id: pinButtonGroup
        }

        ListView {
            id: pinnedMessageListView
            model: chatsModel.messageView.pinnedMessagesList
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            topMargin: Style.current.halfPadding
            anchors.top: parent.top
            anchors.topMargin: -Style.current.halfPadding
            clip: true

            function closePopup() {
                popup.close()
            }
            delegate: Item {
                width: parent.width
                height: messageItem.height

                Message {
                    id: messageItem
                    property var view: ListView.view

                    fromAuthor: model.fromAuthor
                    chatId: model.chatId
                    userName: model.userName
                    alias: model.alias
                    localName: model.localName
                    message: {
                        console.log('Message', model.message, 'plaintext', model.plainText)
                        return model.message
                    }
                    plainText: model.plainText
                    identicon: model.identicon
                    isCurrentUser: model.isCurrentUser
                    timestamp: model.timestamp
                    sticker: model.sticker
                    contentType: model.contentType
                    outgoingStatus: model.outgoingStatus
                    responseTo: model.responseTo
                    imageClick: imagePopup.openPopup.bind(imagePopup)
                    messageId: model.messageId
                    emojiReactions: model.emojiReactions
                    linkUrls: model.linkUrls
                    communityId: model.communityId
                    hasMention: model.hasMention
                    stickerPackId: model.stickerPackId
                    timeout: model.timeout
                    pinnedMessage: true
                    pinnedBy: model.pinnedBy
                    forceHoverHandler: !messageToPin
                    activityCenterMessage: false
                    isEdited: model.isEdited
                    showEdit: false
                    messageContextMenu: MessageContextMenu {
                        showJumpTo: true
                        pinnedMessage: true
                        reactionModel: EmojiReactions { }

                        onCloseParentPopup: {
                            messageItem.view.closePopup()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !!messageToPin
                    cursorShape: Qt.PointingHandCursor
                    z: 55
                    onClicked: radio.toggle()
                }

                StatusRadioButton {
                    id: radio
                    visible: !!messageToPin
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    ButtonGroup.group: pinButtonGroup
                    function toggle() {
                        radio.checked = !radio.checked
                        if (radio.checked) {
                            messageToUnpin = model.messageId
                        }
                    }
                }
            }
        }
    }


    footer: Item {
        width: parent.width
        height: btnBack.height

        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: popup.close()
        }

        StatusButton {
            id: btnUnpin
            visible: !!messageToPin
            enabled: !!messageToUnpin
            text: qsTr("Unpin")
            type: "warn"
            anchors.right: parent.right
            onClicked: {
                const chatId = chatsModel.channelView.activeChannel.id
                chatsModel.messageView.unPinMessage(messageToUnpin, chatId)
                chatsModel.messageView.pinMessage(messageToPin, chatId)
                messageToUnpin = messageToPin = ""
                popup.close()
            }
        }
    }
}
