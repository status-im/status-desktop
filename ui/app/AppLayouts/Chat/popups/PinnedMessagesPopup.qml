import QtQuick 2.13
import QtQuick.Controls 2.3

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

import "../controls"
import "../panels"
//TODO remove or make view?
import "../views"

ModalPopup {
    property var rootStore
    property var messageStore
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
            //% "Pin limit reached"
            text: !!messageToPin ? qsTrId("pin-limit-reached") :
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
                    //% "Unpin a previous message first"
                    return qsTrId("unpin-a-previous-message-first")
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
                id: messageDelegate
                property var listView: ListView.view
                width: parent.width
                height: messageItem.height

                MessageView {
                    id: messageItem
                    rootStore: popup.rootStore
                    messageStore: popup.messageStore
                    Component.onCompleted: {
                        messageStore.fromAuthor = model.fromAuthor;
                        messageStore.chatId = model.chatId;
                        messageStore.userName = model.userName;
                        messageStore.alias = model.alias;
                        messageStore.localName = model.localName;
                        messageStore.message = model.message;
                        messageStore.plainText = model.plainText;
                        messageStore.identicon = model.identicon;
                        messageStore.isCurrentUser = model.isCurrentUser;
                        messageStore.timestamp = model.timestamp;
                        messageStore.sticker = model.sticker;
                        messageStore.contentType = model.contentType;
                        messageStore.outgoingStatus = model.outgoingStatus;
                        messageStore.responseTo = model.responseTo;
                        messageStore.imageClick = imagePopup.openPopup.bind(imagePopup);
                        messageStore.messageId = model.messageId;
                        messageStore.emojiReactions = model.emojiReactions;
                        messageStore.linkUrls = model.linkUrls;
                        messageStore.communityId = model.communityId;
                        messageStore.hasMention = model.hasMention;
                        messageStore.stickerPackId = model.stickerPackId;
                        messageStore.timeout = model.timeout;
                        messageStore.pinnedMessage = true;
                        messageStore.pinnedBy = model.pinnedBy;
                        messageStore.forceHoverHandler = !messageToPin;
                        messageStore.activityCenterMessage = false;
                        messageStore.isEdited = model.isEdited;
                        messageStore.showEdit = false;
                        messageStore.messageContextMenu = msgContextMenu;
                    }
                    MessageContextMenuPanel {
                        id: msgContextMenu
                        pinnedPopup: true
                        pinnedMessage: true
                        reactionModel: popup.rootStore.emojiReactionsModel
                        onShouldCloseParentPopup: {
                            messageDelegate.listView.closePopup();
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
        height: btnUnpin.height

        StatusButton {
            id: btnUnpin
            visible: !!messageToPin
            enabled: !!messageToUnpin
            //% "Unpin"
            text: qsTrId("unpin")
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
