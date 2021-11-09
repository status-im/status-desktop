import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml.Models 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.status 1.0
import shared.controls 1.0

import "../Chat/views"
import "../Chat/popups"
import "../Chat/stores"

import "stores"
import "panels"

ScrollView {
    id: root

    property RootStore store: RootStore { }

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: chatLogView.contentHeight + 140
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    
    property var rootStore
    property var messageStore
    property var onActivated: function () {
        store.setActiveChannelToTimeline()
        statusUpdateInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Component.onCompleted: {
        statusUpdateInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function openProfilePopup(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, parentPopup){
        var popup = profilePopupComponent.createObject(root);
        if(parentPopup){
            popup.parentPopup = parentPopup;
        }
        popup.openPopup(root.store.profileModelInst.profile.pubKey !== fromAuthorParam, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam);
    }

    StatusImageModal {
        id: imagePopup
        onClicked: {
            close()
        }
    }

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        store: root.store
        onClosed: {
            if(profilePopup.parentPopup){
                profilePopup.parentPopup.close();
            }
            destroy()
        }
    }

    Item {
        id: timelineContainer
        width: 624
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        // TODO: Replace this with StatusQ component once it lives there.
        StatusChatInput {
            id: statusUpdateInput
            anchors.top: parent.top
            anchors.topMargin: 40
            chatType: Constants.chatTypeStatusUpdate
            imageErrorMessageLocation: StatusChatInput.ImageErrorMessageLocation.Bottom
            z: 1
            onSendMessage: {
                if (statusUpdateInput.fileUrls.length > 0){
                    statusUpdateInput.fileUrls.forEach(url => {
                        root.store.sendImage(url);
                    })
                }
                var msg = root.store.getPlainTextFromRichText(Emoji.deparse(statusUpdateInput.textInput.text))
                if (msg.length > 0){
                    msg = statusUpdateInput.interpretMessage(msg)
                    root.store.sendMessage(msg, Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType);
                    statusUpdateInput.textInput.text = "";
                    if(event) event.accepted = true
                    sendMessageSound.stop()
                    Qt.callLater(sendMessageSound.play);
                }
            }
        }

        EmptyTimelinePanel {
            id: emptyTimeline
            anchors.top: statusUpdateInput.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            visible: chatLogView.count === 0
        }

        ListView {
            id: chatLogView
            anchors.top: statusUpdateInput.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: Style.current.halfPadding
            flickDeceleration: 10000
            interactive: false

            model: messageListDelegate
            section.property: "sectionIdentifier"
            section.criteria: ViewSection.FullString

            Connections {
                target: root.store.chatsModelInst.messageView
                onMessagesLoaded: {
                    Qt.callLater(chatLogView.positionViewAtBeginning)
                }
            }
        }

        Timer {
            id: ageUpdateTimer
            property int epoch: 0
            running: true
            repeat: true
            interval: 60000 // 1 min
            onTriggered: epoch = epoch + 1
        }

        DelegateModelGeneralized {
            id: messageListDelegate
            lessThan: [
                function(left, right) { return left.clock > right.clock }
            ]
            model: root.store.chatsModelInst.messageView.messageList
            // TODO: Replace with StatusQ component once it lives there.
            delegate: MessageView {
                id: msgDelegate
                rootStore: root.rootStore
                messageStore: root.messageStore
                /////////TODO Remove
                fromAuthor: model.fromAuthor
                chatId: model.chatId
                userName: model.userName
                alias: model.alias
                localName: model.localName
                message: model.message
                plainText: model.plainText
                identicon: model.identicon
                isCurrentUser: model.isCurrentUser
                timestamp: model.timestamp
                sticker: model.sticker
                contentType: model.contentType
                outgoingStatus: model.outgoingStatus
                responseTo: model.responseTo
                authorCurrentMsg: msgDelegate.ListView.section
                authorPrevMsg: msgDelegate.ListView.previousSection
                imageClick: imagePopup.openPopup.bind(imagePopup)
                messageId: model.messageId
                emojiReactions: model.emojiReactions
                isStatusUpdate: true
                statusAgeEpoch: ageUpdateTimer.epoch
                // This is used in order to have access to the previous message and determine the timestamp
                // we can't rely on the index because the sequence of messages is not ordered on the nim side
                prevMessageIndex: {
                    // This is used in order to have access to the previous message and determine the timestamp
                    // we can't rely on the index because the sequence of messages is not ordered on the nim side
                    if(msgDelegate.DelegateModel.itemsIndex > 0){
                        return messageListDelegate.items.get(msgDelegate.DelegateModel.itemsIndex - 1).model.index
                    }
                    return -1;
                }
                timeout: model.timeout
                messageContextMenu: msgCntxtMenu
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
                    messageStore.authorCurrentMsg = msgDelegate.ListView.section;
                    messageStore.authorPrevMsg = msgDelegate.ListView.previousSection;
                    messageStore.imageClick = imagePopup.openPopup.bind(imagePopup);
                    messageStore.messageId = model.messageId;
                    messageStore.emojiReactions = model.emojiReactions;
                    messageStore.isStatusUpdate = true;
                    messageStore.statusAgeEpoch = ageUpdateTimer.epoch;
                    // This is used in order to have access to the previous message and determine the timestamp
                    // we can't rely on the index because the sequence of messages is not ordered on the nim side
                    messageStore.prevMessageIndex =
                        // This is used in order to have access to the previous message and determine the timestamp
                        // we can't rely on the index because the sequence of messages is not ordered on the nim side
                        (msgDelegate.DelegateModel.itemsIndex > 0) ?
                        messageListDelegate.items.get(msgDelegate.DelegateModel.itemsIndex - 1).model.index : -1;
                    messageStore.timeout = model.timeout;
                    messageStore.messageContextMenu = msgCntxtMenu;
                }
                MessageContextMenuView {
                    id: msgCntxtMenu
                    store: root.store
                    reactionModel: EmojiReactions { }
                }
            }
        }

        Loader {
            active: root.store.chatsModelInst.messageView.loadingMessages
            // TODO: replace with StatusLoadingIndicator
            sourceComponent: LoadingAnimation {}
            anchors.right: timelineContainer.right
            anchors.top: statusUpdateInput.bottom
            anchors.rightMargin: Style.current.padding
            anchors.topMargin: Style.current.padding
        }
    }
}
