import QtQuick 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../shared/status/core"

import "../panels"
import "../views"
import "../controls"
import "../controls/messages"
import utils 1.0

Item {
    id: root
    width: parent.width
    anchors.right: !messageStore.isCurrentUser ? undefined : parent.right
    height: visible ? childrenRect.height : 0
    z: (typeof chatLogView === "undefined") ? 1 : (chatLogView.count - index)

    property var rootStore
    property var messageStore
    function startMessageFoundAnimation() {
        messageLoader.item.startMessageFoundAnimation();
    }

    Connections {
        enabled: !messageStore.placeholderMessage
        target: rootStore.profileModelInst.contacts.list
        onContactChanged: {
            if (rootStore.profileModelInst.profile.pubkey === messageStore.fromAuthor) {
                const img = appMain.getProfileImage(messageStore.userPubKey, messageStore.isCurrentUser, messageStore.useLargeImage)
                if (img) {
                    messageStore.profileImageSource = img
                }
            } else if (messageStore.replyMessageIndex > -1 && pubkey === messageStore.repliedMessageAuthorPubkey) {
                const imgReply = appMain.getProfileImage(messageStore.repliedMessageAuthorPubkey, messageStore.repliedMessageAuthorIsCurrentUser, false)
                if (imgReply) {
                    messageStore.repliedMessageUserImage = imgReply
                }
            }
        }
    }

    Connections {
        target: rootStore.chatsModelInst.messageView
        onHideMessage: {
            // This hack is used because message_list deleteMessage sometimes does not remove the messages (there might be an issue with the delegate model)
            if(mId === messageStore.messageId){
                root.visible = 0;
                root.height = 0;
            }
        }
    }

    Loader {
        id: messageLoader
        width: parent.width
        sourceComponent: {
            switch(messageStore.contentType) {
                case Constants.chatIdentifier:
                    return channelIdentifierComponent
                case Constants.fetchMoreMessagesButton:
                    return fetchMoreMessagesButtonComponent
                case Constants.systemMessagePrivateGroupType:
                    return privateGroupHeaderComponent
                case Constants.gapType:
                    return gapComponent
                default:
                    return messageStore.isStatusUpdate ? statusUpdateComponent :
                                            (appSettings.useCompactMode ? compactMessageComponent : messageComponent)
            }
        }
    }

    Component {
        id: gapComponent
        GapComponent {
            onClicked: {
                rootStore.chatsModelInst.messageView.fillGaps(messageStore.messageId)
                root.visible = false;
                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
            nextMessageIndex: root.messageStore.nextMessageIndex
            nextMsgTimestamp: root.messageStore.nextMsgTimestamp
            onClicked: {
                rootStore.chatsModelInst.messageView.hideLoadingIndicator();
            }
            onTimerTriggered: {
                rootStore.chatsModelInst.requestMoreMessages(Constants.fetchRangeLast24Hours);
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifierView {
            authorCurrentMsg: messageStore.authorCurrentMsg
            profileImage: messageStore.profileImageSource
        }
    }

    // Private group Messages
    Component {
        id: privateGroupHeaderComponent
        StyledText {
            wrapMode: Text.Wrap
            text: {
                return `<html>`+
                `<head>`+
                    `<style type="text/css">`+
                    `a {`+
                        `color: ${Style.current.textColor};`+
                        `text-decoration: none;`+
                    `}`+
                    `</style>`+
                `</head>`+
                `<body>`+
                    `${message}`+
                `</body>`+
            `</html>`;
            }
            visible: messageStore.isStatusMessage
            font.pixelSize: 14
            color: Style.current.secondaryText
            width:  parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
            topPadding: messageStore.prevMessageIndex === 1 ? Style.current.bigPadding : 0
        }
    }

    Component {
        id: messageComponent
        NormalMessageView {
            store: root.rootStore
            messageStore: root.messageStore
            linkUrls: messageStore.linkUrls
            isCurrentUser: messageStore.isCurrentUser
            contentType: messageStore.contentType
            container: root
        }
    }

    Component {
        id: statusUpdateComponent
        StatusUpdatePanel {
            container: root
            statusAgeEpoch: messageStore.statusAgeEpoch
            emojiReactionsModel: messageStore.emojiReactionsModel
            messageContextMenu: messageStore.messageContextMenu
            timestamp: messageStore.timestamp
            isCurrentUser: messageStore.isCurrentUser
            isMessageActive: messageStore.isMessageActive
            displayUserName: messageStore.displayUserName
            userName: messageStore.userName
            isImage: messageStore.isImage
            isMessage: messageStore.isMessage
            profileImageSource: messageStore.profileImageSource
            userIdenticon: messageStore.identicon
            onAddEmoji: {
                root.messageStore.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
            onChatImageClicked: {
                messageStore.imageClick(image);
            }
            onUserNameChanged: {
                root.messageStore.clickMessage(isProfileClick);
            }
            onEmojiBtnClicked: {
                root.messageStore.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly);
            }
            onClickMessage: {
                root.messageStore.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
            onSetMessageActive: {
                root.messageStore.setMessageActive(messageId, active);;
            }
        }
    }

    Component {
        id: compactMessageComponent
        CompactMessageView {
            store: root.rootStore
            messageStore: root.messageStore
            linkUrls: messageStore.linkUrls
            isCurrentUser: messageStore.isCurrentUser
            contentType: messageStore.contentType
            showEdit: messageStore.showEdit
            container: root
            messageContextMenu: messageStore.messageContextMenu
            onAddEmoji: {
                root.clickMessage(isProfileClick, isSticker, isImage , image, emojiOnly, hideEmojiPicker);
            }
        }
    }
}
