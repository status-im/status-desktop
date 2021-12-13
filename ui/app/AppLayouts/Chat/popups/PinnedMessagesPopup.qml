import QtQuick 2.13
import QtQuick.Controls 2.3

import utils 1.0
import shared 1.0
import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.views.chat 1.0

import "../controls"
import "../panels"
//TODO remove or make view?
import "../views"

import StatusQ.Controls 0.1 as StatusQControls

// TODO: replace with StatusMOdal
ModalPopup {
    property var rootStore
    property var messageStore
    property var chatSectionModule
    property bool userCanPin: {
        // Not Refactored Yet
        return false
//        switch (popup.rootStore.chatsModelInst.channelView.activeChannel.chatType) {
//        case Constants.chatType.publicChat: return false
//        case Constants.chatType.profile: return false
//        case Constants.chatType.oneToOne: return true
//        case Constants.chatType.privateGroupChat: return popup.rootStore.chatsModelInst.channelView.activeChannel.isAdmin(userProfile.pubKey)
//        case Constants.chatType.communityChat: return popup.rootStore.chatsModelInst.communities.activeCommunity.admin
//        default: return false
//        }
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
            // Not Refactored Yet
//            model: popup.rootStore.chatsModelInst.messageView.pinnedMessagesList
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            topMargin: Style.current.halfPadding
            anchors.top: parent.top
            anchors.topMargin: -Style.current.halfPadding
            clip: true
            
            delegate: Item {
                id: messageDelegate
                property var listView: ListView.view
                width: parent.width
                height: messageItem.height

                MessageView {
                    id: messageItem
//                    rootStore: popup.rootStore
//                    messageStore: popup.messageStore
                    /////////////TODO Remove
//                    fromAuthor: model.fromAuthor
//                    chatId: model.chatId
//                    userName: model.userName
//                    alias: model.alias
//                    localName: model.localName
//                    message: model.message
//                    plainText: model.plainText
//                    identicon: model.identicon
//                    isCurrentUser: model.isCurrentUser
//                    timestamp: model.timestamp
//                    sticker: model.sticker
//                    contentType: model.contentType
//                    outgoingStatus: model.outgoingStatus
//                    responseTo: model.responseTo
//                    imageClick: imagePopup.openPopup.bind(imagePopup)
//                    messageId: model.messageId
//                    emojiReactions: model.emojiReactions
//                    linkUrls: model.linkUrls
//                    communityId: model.communityId
//                    hasMention: model.hasMention
//                    stickerPackId: model.stickerPackId
//                    timeout: model.timeout
//                    pinnedMessage: true
//                    pinnedBy: model.pinnedBy
//                    forceHoverHandler: !messageToPin
//                    activityCenterMessage: false
//                    isEdited: model.isEdited
//                    showEdit: false
//                    messageContextMenu: msgContextMenu
//                    Component.onCompleted: {
//                        messageStore.fromAuthor = model.fromAuthor;
//                        messageStore.chatId = model.chatId;
//                        messageStore.userName = model.userName;
//                        messageStore.alias = model.alias;
//                        messageStore.localName = model.localName;
//                        messageStore.message = model.message;
//                        messageStore.plainText = model.plainText;
//                        messageStore.identicon = model.identicon;
//                        messageStore.isCurrentUser = model.isCurrentUser;
//                        messageStore.timestamp = model.timestamp;
//                        messageStore.sticker = model.sticker;
//                        messageStore.contentType = model.contentType;
//                        messageStore.outgoingStatus = model.outgoingStatus;
//                        messageStore.responseTo = model.responseTo;
//                        messageStore.imageClick = imagePopup.openPopup.bind(imagePopup);
//                        messageStore.messageId = model.messageId;
//                        messageStore.emojiReactions = model.emojiReactions;
//                        messageStore.linkUrls = model.linkUrls;
//                        messageStore.communityId = model.communityId;
//                        messageStore.hasMention = model.hasMention;
//                        messageStore.stickerPackId = model.stickerPackId;
//                        messageStore.timeout = model.timeout;
//                        messageStore.pinnedMessage = true;
//                        messageStore.pinnedBy = model.pinnedBy;
//                        messageStore.forceHoverHandler = !messageToPin;
//                        messageStore.activityCenterMessage = false;
//                        messageStore.isEdited = model.isEdited;
//                        messageStore.showEdit = false;
//                        messageStore.messageContextMenu = msgContextMenu;
//                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !!messageToPin
                    cursorShape: Qt.PointingHandCursor
                    z: 55
                    onClicked: radio.toggle()
                }

                StatusQControls.StatusRadioButton {
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
        MessageContextMenuView {
            id: msgContextMenu
            pinnedPopup: true
            pinnedMessage: true
            chatSectionModule: popup.chatSectionModule
            store: popup.rootStore
            reactionModel: popup.rootStore.emojiReactionsModel
            onShouldCloseParentPopup: {
                popup.close()
            }
        }
    }


    footer: Item {
        width: parent.width
        height: btnUnpin.height

        StatusQControls.StatusButton {
            id: btnUnpin
            visible: !!messageToPin
            enabled: !!messageToUnpin
            //% "Unpin"
            text: qsTrId("unpin")
            type: StatusQControls.StatusBaseButton.Type.Danger
            anchors.right: parent.right
            onClicked: {
                // Not Refactored Yet
//                const chatId = popup.rootStore.chatsModelInst.channelView.activeChannel.id
//                popup.rootStore.chatsModelInst.messageView.unPinMessage(messageToUnpin, chatId)
//                popup.rootStore.chatsModelInst.messageView.pinMessage(messageToPin, chatId)
                messageToUnpin = messageToPin = ""
                popup.close()
            }
        }
    }
}
