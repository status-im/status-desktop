import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0

import StatusQ.Controls 0.1 as StatusQControls

import "../../../../shared/panels"
import "../../../../shared/controls"
import "../../../../shared/status"
import "../panels"
import "../controls"

Item {
    id: root
    property var store
    property var messageStore
    property int chatHorizontalPadding: Style.current.halfPadding
    property int chatVerticalPadding: 7
    property string linkUrls: root.messageStore.linkUrls
    property int contentType: 2
    property var container
    property bool isCurrentUser: false
    property bool isHovered: typeof root.messageStore.hoveredMessage !== "undefined" && root.messageStore.hoveredMessage === messageId
    property bool isMessageActive: typeof root.messageStore.activeMessage !== "undefined" && root.messageStore.activeMessage === messageId
    property bool headerRepeatCondition: (authorCurrentMsg !== authorPrevMsg || shouldRepeatHeader || dateGroupLbl.visible || chatReply.active)
    property bool showMoreButton: {
        if (!!root.store) {
            switch (root.store.chatsModelInst.channelView.activeChannel.chatType) {
            case Constants.chatTypeOneToOne: return true
            case Constants.chatTypePrivateGroupChat: return root.store.chatsModelInst.channelView.activeChannel.isAdmin(root.store.profileModelInst.profile.pubKey) ? true : isCurrentUser
            case Constants.chatTypePublic: return isCurrentUser
            case Constants.chatTypeCommunity: return root.store.chatsModelInst.communities.activeCommunity.admin ? true : isCurrentUser
            case Constants.chatTypeStatusUpdate: return false
            default: return false
            }
        }
        else {
            return false;
        }
    }
    property bool showEdit: true
    property var messageContextMenu
    signal addEmoji(bool isProfileClick, bool isSticker, bool isImage , var image, bool emojiOnly, bool hideEmojiPicker)

    width: parent.width
    height: messageContainer.height + messageContainer.anchors.topMargin
            + (dateGroupLbl.visible ? dateGroupLbl.height + dateGroupLbl.anchors.topMargin : 0)

    Timer {
        id: ensureMessageFullyVisibleTimer
        interval: 1
        onTriggered: {
            chatLogView.positionViewAtIndex(ListView.currentIndex, ListView.Contain)
        }
    }

    MouseArea {
        enabled: !placeholderMessage
        anchors.fill: messageContainer
        acceptedButtons: activityCenterMessage ? Qt.LeftButton : Qt.RightButton
        onClicked: {
            messageMouseArea.clicked(mouse)
        }
    }

    ChatButtonsPanel {
        contentType: root.contentType
        parentIsHovered: !isEdit && root.isHovered
        onHoverChanged: {
            hovered && root.messageStore.setHovered(messageId, hovered)
        }
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: messageContainer.top
        // This is not exactly like the design because the hover becomes messed up with the buttons on top of another Message
        anchors.topMargin: -Style.current.halfPadding
        messageContextMenu: root.messageContextMenu
        showMoreButton: root.showMoreButton
        fromAuthor: fromAuthor
        editBtnActive: isText && !isEdit && isCurrentUser && showEdit
        onClickMessage: {
            parent.parent.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly);
        }
    }

    Loader {
        active: typeof messageContextMenu !== "undefined"
        sourceComponent: Component {
            Connections {
                enabled: root.isMessageActive
                target: messageContextMenu
                onClosed: root.messageStore.setMessageActive(messageId, false)
            }
        }
    }

    DateGroup {
        id: dateGroupLbl
        previousMessageIndex: prevMessageIndex
        previousMessageTimestamp: prevMsgTimestamp
        messageTimestamp: timestamp
        isActivityCenterMessage: activityCenterMessage
    }

    function startMessageFoundAnimation() {
        messageFoundAnimation.start();
    }

    SequentialAnimation {
        id: messageFoundAnimation
        PauseAnimation {
            duration: 600
        }
         NumberAnimation {
            target: highlightRect
            property: "opacity"
            to: 1.0
            duration: 1500
        }
        PauseAnimation {
            duration: 1000
        }
        NumberAnimation {
           target: highlightRect
           property: "opacity"
            to: 0.0
            duration: 1500
        }
    }

    Rectangle {
        id: highlightRect
        anchors.fill: messageContainer
        opacity: 0
        visible: (opacity > 0.001)
        color: Style.current.backgroundHoverLight
    }

    Rectangle {
        property alias chatText: chatText

        id: messageContainer
        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: dateGroupLbl.visible ? (activityCenterMessage ? 4 : Style.current.padding) : 0
        height: childrenRect.height
                + (chatName.visible || emojiReactionLoader.active ? Style.current.halfPadding : 0)
                + (chatName.visible && emojiReactionLoader.active ? Style.current.padding : 0)
                + (!chatName.visible && chatImageContent.active ? 6 : 0)
                + (emojiReactionLoader.active ? emojiReactionLoader.height: 0)
                + (retry.visible && !chatTime.visible ? Style.current.smallPadding : 0)
                + (pinnedRectangleLoader.active ? Style.current.smallPadding : 0)
                + (isEdit ? 25 : 0)
        width: parent.width
        color: {
            if (isEdit) {
                return Style.current.backgroundHoverLight
            }

            if (activityCenterMessage) {
                return read ? Style.current.transparent : Utils.setColorAlpha(Style.current.blue, 0.1)
            }

            if (placeholderMessage) {
                return Style.current.transparent
            }

            if (pinnedMessage) {
                return root.isHovered || isMessageActive ? Style.current.pinnedMessageBackgroundHovered : Style.current.pinnedMessageBackground
            }

            return root.isHovered || isMessageActive ? (hasMention ? Style.current.mentionMessageHoverColor : Style.current.backgroundHoverLight) :
                                                       (hasMention ? Style.current.mentionMessageColor : Style.current.transparent)
        }

        Loader {
            id: pinnedRectangleLoader
            active: !isEdit && pinnedMessage
            anchors.left: chatName.left
            anchors.top: parent.top
            anchors.topMargin: active ? Style.current.halfPadding : 0

            sourceComponent: Component {
                Rectangle {
                    id: pinnedRectangle
                    height: 24
                    width: childrenRect.width + Style.current.smallPadding
                    color: Style.current.pinnedRectangleBackground
                    radius: 12

                    SVGImage {
                        id: pinImage
                        source: Style.svg("pin")
                        anchors.left: parent.left
                        anchors.leftMargin: 3
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: Style.current.pinnedMessageBorder
                        }
                    }

                    StyledText {
                        //% "Pinned by %1"
                        text: qsTrId("pinned-by--1").arg(root.store.chatsModelInst.alias(pinnedBy))
                        anchors.left: pinImage.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 13
                    }
                }
            }
        }


        Connections {
            enabled: !!root.store
            target: enabled ? root.store.chatsModelInst.messageView : null
            onMessageEdited: {
                if(chatReply.item)
                    chatReply.item.messageEdited(editedMessageId, editedMessageContent)
            }
        }

        ChatReplyPanel {
            id: chatReply
            anchors.top: pinnedRectangleLoader.active ? pinnedRectangleLoader.bottom : parent.top
            anchors.topMargin: active ? 4 : 0
            anchors.left: chatImage.left
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding

            longReply: active && textFieldImplicitWidth > width
            container: root.container
            chatHorizontalPadding: root.chatHorizontalPadding
            stickerData: !!root.store ? root.store.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "sticker") : null
            active: responseTo !== "" && replyMessageIndex > -1 && !activityCenterMessage
//            To-Do move to store later?
//            isCurrentUser: root.messageStore.isCurrentUser
//            repliedMessageType: root.messageStore.repliedMessageType
//            repliedMessageImage: root.messageStore.repliedMessageImage
//            repliedMessageUserIdenticon: root.messageStore.repliedMessageUserIdenticon
//            repliedMessageIsEdited: root.messageStore.repliedMessageIsEdited
//            repliedMessageUserImage: root.messageStore.repliedMessageUserImage
//            repliedMessageAuthor: root.messageStore.repliedMessageAuthor
//            repliedMessageContent: root.messageStore.repliedMessageContent
//            responseTo: root.messageStore.responseTo
//            onScrollToBottom: {
//                root.messageStore.scrollToBottom(isit, container);
//            }
            onClickMessage: {
                parent.parent.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
        }


        UserImage {
            id: chatImage
            active: isMessage && headerRepeatCondition
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: chatReply.active ? chatReply.bottom :
                                            pinnedRectangleLoader.active ? pinnedRectangleLoader.bottom : parent.top
            anchors.topMargin: chatReply.active || pinnedRectangleLoader.active ? 4 : Style.current.smallPadding
//            messageContextMenu: root.messageStore.messageContextMenu
//            isCurrentUser: root.messageStore.isCurrentUser
//            profileImage: root.messageStore.profileImageSource
//            isMessage: root.messageStore.isMessage
//            identiconImageSource: root.messageStore.identicon
            onClickMessage: {
                parent.parent.parent.parent.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply);
            }
        }

        UsernameLabel {
            id: chatName
            visible: !isEdit && isMessage && headerRepeatCondition
            anchors.leftMargin: root.chatHorizontalPadding
            anchors.top: chatImage.top
            anchors.left: chatImage.right
//            messageContextMenu: root.messageStore.messageContextMenu
//            isCurrentUser: root.messageStore.isCurrentUser
//            localName: root.messageStore.localName
//            userName: root.messageStore.userName
//            displayUserName: root.messageStore.displayUserName
            onClickMessage: {
                parent.parent.parent.parent.clickMessage(true, false, false, null, false, false, false);
            }
        }

        ChatTimePanel {
            id: chatTime
            visible: !isEdit && headerRepeatCondition
            anchors.verticalCenter: chatName.verticalCenter
            anchors.left: chatName.right
            anchors.leftMargin: 4
            color: Style.current.secondaryText
            //timestamp: timestamp
        }

        Loader {
            id: editMessageLoader
            active: isEdit
            anchors.top: chatReply.active ? chatReply.bottom : parent.top
            anchors.left: chatImage.right
            anchors.leftMargin: root.chatHorizontalPadding
            anchors.right: parent.right
            anchors.rightMargin: root.chatHorizontalPadding
            height: (item !== null && typeof(item)!== 'undefined')? item.height: 0
            property string sourceText

            onActiveChanged: {
                if (!active) {
                    return
                }

                let mentionsMap = new Map()
                let index = 0
                while (true) {
                    index = message.indexOf("<a href=", index)
                    if (index < 0) {
                        break
                    }
                    let endIndex = message.indexOf("</a>", index)
                    if (endIndex < 0) {
                        index += 8 // "<a href="
                        continue
                    }
                    let addrIndex = rmessage.indexOf("0x", index + 8)
                    if (addrIndex < 0) {
                        index += 8 // "<a href="
                        continue
                    }
                    let addrEndIndex = message.indexOf('"', addrIndex)
                    if (addrEndIndex < 0) {
                        index += 8 // "<a href="
                        continue
                    }
                    const address = '@' + message.substring(addrIndex, addrEndIndex)
                    const linkTag = message.substring(index, endIndex + 5)
                    const linkText = linkTag.replace(/(<([^>]+)>)/ig,"").trim()
                    const atSymbol = linkText.startsWith("@") ? '' : '@'
                    const mentionTag = Constants.mentionSpanTag + atSymbol + linkText + '</span> '
                    mentionsMap.set(address, mentionTag)
                    index += linkTag.length
                }

                sourceText = plainText
                for (let [key, value] of mentionsMap) {
                    sourceText = sourceText.replace(new RegExp(key, 'g'), value)
                }
                sourceText = sourceText.replace(/\n/g, "<br />")
                sourceText = Utils.getMessageWithStyle(sourceText, appSettings.useCompactMode, isCurrentUser)
            }

            sourceComponent: Item {
                id: editText
                height: childrenRect.height

                property bool suggestionsOpened: false
                Keys.onEscapePressed: {
                    if (!suggestionsOpened) {
                        cancelBtn.clicked()
                    }
                    suggestionsOpened = false
                }

                StatusChatInput {
                    id: editTextInput
                    chatInputPlaceholder: qsTrId("type-a-message-")
                    chatType: root.store.chatsModelInst.channelView.activeChannel.chatType
                    isEdit: true
                    textInput.text: editMessageLoader.sourceText
                    onSendMessage: {
                        saveBtn.clicked()
                    }
                    suggestions.onVisibleChanged: {
                        if (suggestions.visible) {
                            editText.suggestionsOpened = true
                        }
                    }
                }

                StatusQControls.StatusFlatButton {
                    id: cancelBtn
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.halfPadding
                    anchors.top: editTextInput.bottom
                    //% "Cancel"
                    text: qsTrId("browsing-cancel")
                    onClicked: {
                        isEdit = false
                        editTextInput.textInput.text = Emoji.parse(message)
                        ensureMessageFullyVisibleTimer.start()
                    }
                }

                StatusQControls.StatusButton {
                    id: saveBtn
                    anchors.left: cancelBtn.right
                    anchors.leftMargin: Style.current.halfPadding
                    anchors.top: editTextInput.bottom
                    //% "Save"
                    text: qsTrId("save")
                    enabled: editTextInput.textInput.text.trim().length > 0
                    onClicked: {
                        let msg = root.store.chatsModelInst.plainText(Emoji.deparse(editTextInput.textInput.text))
                        if (msg.length > 0){
                            msg = chatInput.interpretMessage(msg)
                            isEdit = false
                            root.store.chatsModelInst.messageView.editMessage(messageId, contentType == Constants.editType ? replaces : messageId, msg);
                        }
                    }
                }
            }
        }

        Item {
            id: messageContent
            height: childrenRect.height + (isEmoji ? 2 : 0)
            anchors.top: chatName.visible ? chatName.bottom :
                                            chatReply.active ? chatReply.bottom :
                                                pinnedRectangleLoader.active ? pinnedRectangleLoader.bottom : parent.top
            anchors.left: chatImage.right
            anchors.leftMargin: root.chatHorizontalPadding
            anchors.right: parent.right
            anchors.rightMargin: root.chatHorizontalPadding
            visible: !isEdit

            ChatTextView {
                id: chatText
                store: root.store
                messageStore: root.messageStore
                readonly property int leftPadding: chatImage.anchors.leftMargin + chatImage.width + root.chatHorizontalPadding
                visible: {
                    const urls = root.linkUrls.split(" ")
                    if (urls.length === 1 && Utils.hasImageExtension(urls[0]) && appSettings.displayChatImages) {
                        return false
                    }

                    return isText || isEmoji
                }

                anchors.top: parent.top
                anchors.topMargin: isEmoji ? 2 : 0
                anchors.left: parent.left
                anchors.right: parent.right
                // using a padding instead of a margin let's us select text more easily
                anchors.leftMargin: -leftPadding
                textField.leftPadding: leftPadding
                textField.rightPadding: Style.current.bigPadding

                onLinkActivated: {
                    if (activityCenterMessage) {
                        clickMessage(false, isSticker, false)
                    }
                }
            }

            Loader {
                id: chatImageContent
                active: isImage
                anchors.top: parent.top
                anchors.topMargin: active ? 6 : 0
                z: 51
                sourceComponent: Component {
                    StatusChatImage {
                        imageSource: profileImageSource
                        imageWidth: 200
                        onClicked: {
                            if (mouse.button === Qt.LeftButton) {
                                root.messageStore.imageClick(image)
                            }
                            else if (mouse.button === Qt.RightButton) {
                                // Set parent, X & Y positions for the messageContextMenu
                                messageContextMenu.parent = root
                                messageContextMenu.setXPosition = function() { return (mouse.x)}
                                messageContextMenu.setYPosition = function() { return (mouse.y)}
                                root.clickMessage(false, false, true, image, false, true, false, true, imageSource)
                            }
                        }
                        container: root.container
                    }
                }
            }

            Loader {
                id: stickerLoader
                active: contentType === Constants.stickerType
                anchors.top: parent.top
                anchors.topMargin: active ? Style.current.halfPadding : 0
                sourceComponent: Component {
                    Rectangle {
                        id: stickerContainer
                        color: Style.current.transparent
                        border.color: root.isHovered ? Qt.darker(Style.current.border, 1.1) : Style.current.border
                        border.width: 1
                        radius: 16
                        width: stickerId.width + 2 * root.chatVerticalPadding
                        height: stickerId.height + 2 * root.chatVerticalPadding

                        StatusSticker {
                            id: stickerId
                            anchors.top: parent.top
                            anchors.topMargin: root.chatVerticalPadding
                            anchors.left: parent.left
                            anchors.leftMargin: root.chatVerticalPadding
                            contentType: root.contentType
                            stickerData: root.messageStore.sticker
                            onLoaded: {
                                root.messageStore.scrollToBottom(true, root.container)
                            }
                        }
                    }
                }
            }

            MessageMouseArea {
                id: messageMouseArea
                anchors.fill: stickerLoader.active ? stickerLoader : chatText
                z: activityCenterMessage ? chatText.z + 1 : chatText.z -1
                messageContextMenu: root.messageContextMenu
                isActivityCenterMessage: activityCenterMessage
                onClickMessage: {
                    parent.parent.parent.parent.parent.clickMessage(isProfileClick, isSticker, isImage);
                }
                onSetMessageActive: {
                    root.messageStore.setMessageActive(messageId, active);
                }
            }

            Loader {
                id: linksLoader
                active: !!root.linkUrls
                anchors.top: chatText.bottom
                anchors.topMargin: active ? Style.current.halfPadding : 0

                sourceComponent: Component {
                    LinksMessageView {
                        store: root.store
                        linkUrls: root.linkUrls
                        container: root.container
                        isCurrentUser: root.isCurrentUser
                    }
                }
            }

            Loader {
                id: audioPlayerLoader
                active: isAudio
                anchors.top: parent.top
                anchors.topMargin: active ? Style.current.halfPadding : 0

                sourceComponent: Component {
                    AudioPlayerPanel {
                        audioSource: audio
                    }
                }
            }

            Loader {
                id: transactionBubbleLoader
                active: contentType === Constants.transactionType
                anchors.top: parent.top
                anchors.topMargin: active ? (chatName.visible ? 4 : 6) : 0
                sourceComponent: Component {
                    TransactionBubbleView {
                        store: root.store
                    }
                }
            }

            Loader {
                active: contentType === Constants.communityInviteType
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: active ? 8 : 0
                sourceComponent: Component {
                    id: invitationBubble
                    InvitationBubbleView {
                        store: root.store
                        communityId: container.communityId
                    }
                }
            }
        }


        Retry {
            id: retry
            anchors.left: chatTime.visible ? chatTime.right : messageContent.left
            anchors.leftMargin: chatTime.visible ? chatHorizontalPadding : 0
            anchors.top: chatTime.visible ? chatTime.top : messageContent.bottom
            anchors.topMargin: chatTime.visible ? 0 : -4
            anchors.bottom: chatTime.visible ? chatTime.bottom : undefined
            isCurrentUser: root.isCurrentUser
            onClicked: {
                root.store.chatsModelInst.messageView.resendMessage(chatId, messageId)
            }
        }
    }

    Loader {
        active: !activityCenterMessage && (hasMention || pinnedMessage)
        height: messageContainer.height
        anchors.left: messageContainer.left
        anchors.top: messageContainer.top

        sourceComponent: Component {
            Rectangle {
                id: mentionBorder
                color: pinnedMessage ? Style.current.pinnedMessageBorder : Style.current.mentionColor
                width: 2
                height: parent.height
            }
        }
    }

    HoverHandler {
        enabled: !activityCenterMessage &&
                 (forceHoverHandler || (typeof messageContextMenu !== "undefined" && typeof profilePopupOpened !== "undefined" && !messageContextMenu.opened && !profilePopupOpened && !popupOpened))
        onHoveredChanged: {
            root.messageStore.setHovered(messageId, hovered);
        }
    }

    Loader {
        id: emojiReactionLoader
        active: emojiReactionsModel.length
        anchors.bottom: messageContainer.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.left: messageContainer.left
        anchors.leftMargin: messageContainer.chatText.textField.leftPadding

        sourceComponent: Component {
            EmojiReactionsPanel {
                id: emojiRect
//                emojiReactionsModel: root.messageStore.emojiReactionsModel
                onHoverChanged: {
                    root.messageStore.setHovered(messageId, hovered)
                }
//                isMessageActive: root.messageStore.isMessageActive
                onAddEmojiClicked: {
                    root.addEmoji(false, false, false, null, true, false);
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = emojiReactionLoader
                    messageContextMenu.setXPosition = function() { return (messageContextMenu.parent.x + 4)}
                    messageContextMenu.setYPosition = function() { return (-messageContextMenu.height - 4)}
                }
                onToggleReaction: root.store.chatsModelInst.toggleReaction(messageId, emojiID)

                onSetMessageActive: {
                    root.messageStore.setMessageActive(messageId, active);;
                }
            }
        }
    }
}
