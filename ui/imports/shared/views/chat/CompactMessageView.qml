﻿import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.panels.chat 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

import StatusQ.Controls 0.1 as StatusQControls

Item {
    id: root

    property var messageStore
    property var contactsStore

    property var messageContextMenu
    property var container
    property int contentType

    property int chatHorizontalPadding: Style.current.halfPadding
    property int chatVerticalPadding: 7
    property bool headerRepeatCondition: (authorCurrentMsg !== authorPrevMsg ||
                                          shouldRepeatHeader || dateGroupLbl.visible || chatReply.active)
    property bool stickersLoaded: false
    property string sticker
    property int stickerPack
    property bool isMessageActive: false
    property bool isCurrentUser: false
    property bool isHovered: false
    property bool isInPinnedPopup: false
    property bool showMoreButton: {
        if(!root.messageStore)
            return false

        let chatTypeThisMessageBelongsTo = root.messageStore.getChatType()
        switch (chatTypeThisMessageBelongsTo) {
        case Constants.chatType.oneToOne:
            return true
        case Constants.chatType.privateGroupChat:
            return messageStore.amIChatAdmin() || amISender
        case Constants.chatType.publicChat:
            return amISender
        case Constants.chatType.communityChat:
            return messageStore.amIChatAdmin() || amISender
        case Constants.chatType.profile:
            return false
        default:
            return false
        }
    }
    property bool editModeOn: false
    property string linkUrls: ""

    signal openStickerPackPopup(string stickerPackId)
    signal addEmoji(bool isProfileClick, bool isSticker, bool isImage , var image, bool emojiOnly, bool hideEmojiPicker)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool emojiOnly, bool hideEmojiPicker, bool isReply, bool isRightClickOnImage, string imageSource)
    signal replyClicked(string messageId, string author)
    signal imageClicked(var image)

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

    MessageMouseArea {
        enabled: !placeholderMessage && !isImage
        anchors.fill: messageContainer
        acceptedButtons: activityCenterMessage ? Qt.LeftButton : Qt.RightButton
        messageContextMenu: root.messageContextMenu
        messageContextMenuParent: root
        isHovered: root.isHovered
        isMessageActive: root.isMessageActive
        isActivityCenterMessage: activityCenterMessage
        stickersLoaded: root.stickersLoaded
        onClickMessage: {
            root.clickMessage(isProfileClick, isSticker, isImage, null, false, false, false, false, "");
        }
    }

    ChatButtonsPanel {
        contentType: messageContentType
        parentIsHovered: !editModeOn && isHovered
        onHoverChanged: {
            hovered && setHovered(messageId, hovered)
        }
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: messageContainer.top
        // This is not exactly like the design because the hover becomes messed up with the buttons on top of another Message
        anchors.topMargin: -Style.current.halfPadding
        messageContextMenu: root.messageContextMenu
        showMoreButton: root.showMoreButton
        isInPinnedPopup: root.isInPinnedPopup
        fromAuthor: senderId
        editBtnActive: isText && !editModeOn && root.isCurrentUser
        activityCenterMsg: activityCenterMessage
        placeholderMsg: placeholderMessage
        onClickMessage: {
            root.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, false, false, "");
        }
        onReplyClicked: {
            root.replyClicked(messageId, author)
        }
    }

    Loader {
        active: typeof root.messageContextMenu !== "undefined"
        sourceComponent: Component {
            Connections {
                enabled: isMessageActive
                target: root.messageContextMenu
                onClosed: setMessageActive(messageId, false)
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
        id: messageContainer

        property alias messageContent: messageContent

        anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
        anchors.topMargin: dateGroupLbl.visible ? (activityCenterMessage ? 4 : Style.current.padding) : 0
        height: childrenRect.height
                + (chatName.visible || emojiReactionLoader.active ? Style.current.halfPadding : 0)
                + (chatName.visible && emojiReactionLoader.active ? Style.current.padding : 0)
                + (!chatName.visible && chatImageContent.active ? 6 : 0)
                + (emojiReactionLoader.active ? emojiReactionLoader.height: 0)
                + (retry.visible && !chatTime.visible ? Style.current.smallPadding : 0)
                + (pinnedRectangleLoader.active ? Style.current.smallPadding : 0)
                + (editModeOn ? 25 : 0)
        width: parent.width

        color: {
            if (editModeOn) {
                return Style.current.backgroundHoverLight
            }

            if (activityCenterMessage) {
                return read ? Style.current.transparent : Utils.setColorAlpha(Style.current.blue, 0.1)
            }

            if (placeholderMessage) {
                return Style.current.transparent
            }

            if (pinnedMessage) {
                return isHovered || isMessageActive ? Style.current.pinnedMessageBackgroundHovered : Style.current.pinnedMessageBackground
            }

            return isHovered || isMessageActive ? (hasMention ? Style.current.mentionMessageHoverColor : Style.current.backgroundHoverLight) :
                                                       (hasMention ? Style.current.mentionMessageColor : Style.current.transparent)
        }

        Loader {
            id: pinnedRectangleLoader
            active: !editModeOn && pinnedMessage
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
                        text: qsTrId("pinned-by--1").arg(Utils.getContactDetailsAsJson(messagePinnedBy).displayName)
                        anchors.left: pinImage.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 13
                    }
                }
            }
        }


        // Not Refactored Yet
//        Connections {
//            enabled: !!rootStore
//            target: enabled ? rootStore.chatsModelInst.messageView : null
//            onMessageEdited: {
//                if(chatReply.item)
//                    chatReply.item.messageEdited(editedMessageId, editedMessageContent)
//            }
//        }

        ChatReplyPanel {
            id: chatReply
            anchors.top: pinnedRectangleLoader.active ? pinnedRectangleLoader.bottom : parent.top
            anchors.topMargin: active ? 4 : 0
            anchors.left: chatImage.left
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            isCurrentUser: root.isCurrentUser
            longReply: active && textFieldImplicitWidth > width
            container: root.container
            chatHorizontalPadding: chatHorizontalPadding
            // Not Refactored Yet
//            stickerData: !!rootStore ? rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "sticker") : null
            active: responseTo !== "" && !activityCenterMessage

            Component.onCompleted: {
                if(!root.messageStore)
                    return
                let obj = root.messageStore.getMessageByIdAsJson(responseTo)
                if(!obj)
                    return

                amISenderOfTheRepliedMessage = obj.amISender
                repliedMessageContentType = obj.contentType
                repliedMessageSenderIcon = obj.senderIcon
                repliedMessageSenderIconIsIdenticon = obj.isSenderIconIdenticon
                // TODO: not sure about is edited at the moment
                repliedMessageIsEdited = false
                repliedMessageSender = obj.senderDisplayName
                repliedMessageContent = obj.messageText
                repliedMessageImage = obj.messageImage
            }
            onScrollToBottom: {
                // Not Refactored Yet
//                messageStore.scrollToBottom(isit, root.container);
            }

            onClickMessage: {
                root.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply, false, "")
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
            icon: senderIcon
            isIdenticon: isSenderIconIdenticon
            onClickMessage: {
                root.clickMessage(isProfileClick, isSticker, isImage, image, emojiOnly, hideEmojiPicker, isReply, false, "")
            }
        }

        UsernameLabel {
            id: chatName
            visible: !editModeOn && isMessage && headerRepeatCondition
            anchors.leftMargin: chatHorizontalPadding
            anchors.top: chatImage.top
            anchors.left: chatImage.right
            messageContextMenu: root.messageContextMenu
            displayName: senderDisplayName
            localName: senderLocalName
            amISender: amISender
            onClickMessage: {
                root.clickMessage(true, false, false, null, false, false, false, false, "")
            }
        }

        ChatTimePanel {
            id: chatTime
            visible: !editModeOn && headerRepeatCondition
            anchors.verticalCenter: chatName.verticalCenter
            anchors.left: chatName.right
            anchors.leftMargin: 4
            color: Style.current.secondaryText
            timestamp: messageTimestamp
        }

        Loader {
            id: editMessageLoader
            active: editModeOn
            anchors.top: chatReply.active ? chatReply.bottom : parent.top
            anchors.left: chatImage.right
            anchors.leftMargin: chatHorizontalPadding
            anchors.right: parent.right
            anchors.rightMargin: chatHorizontalPadding
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

                sourceText =  rootStore.plainText(Emoji.deparse(message))
                for (let [key, value] of mentionsMap) {
                    sourceText = sourceText.replace(new RegExp(key, 'g'), value)
                }
                sourceText = sourceText.replace(/\n/g, "<br />")
                sourceText = Utils.getMessageWithStyle(sourceText, isCurrentUser)
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
                    chatType: messageStore.getChatType()
                    isEdit: true
                    textInput.text: editMessageLoader.sourceText
                    messageContextMenu: root.messageContextMenu
                    onSendMessage: {
                        saveBtn.clicked(null)
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
                        messageStore.setEditModeOff(messageId)
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
                        let msg = rootStore.plainText(Emoji.deparse(editTextInput.textInput.text))
                        if (msg.length > 0){
                            msg = messageStore.interpretMessage(msg)
                            messageStore.setEditModeOff(messageId)
                            messageStore.editMessage(messageId, msg)
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
            anchors.left: parent.left
            anchors.leftMargin: chatImage.imageWidth + Style.current.padding + root.chatHorizontalPadding
            anchors.right: parent.right
            anchors.rightMargin: root.chatHorizontalPadding
            visible: !editModeOn
            ChatTextView {
                id: chatText
                readonly property int leftPadding: chatImage.anchors.leftMargin + chatImage.width + chatHorizontalPadding
                visible: {
                    const urls = linkUrls.split(" ")
                    if (urls.length === 1 && Utils.hasImageExtension(urls[0]) && localAccountSensitiveSettings.displayChatImages) {
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
                        root.clickMessage(false, isSticker, false, null, false, false, false, false, "")
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
                        imageSource: messageImage
                        imageWidth: 200
                        onClicked: {
                            if (mouse.button === Qt.LeftButton) {
                                root.imageClicked(image)
                            }
                            else if (mouse.button === Qt.RightButton) {
                                // Set parent, X & Y positions for the messageContextMenu
                                root.messageContextMenu.parent = root
                                root.messageContextMenu.setXPosition = function() { return (mouse.x)}
                                root.messageContextMenu.setYPosition = function() { return (mouse.y)}
                                root.clickMessage(false, false, true, image, false, true, false, true, imageSource)
                            }
                        }
                        container: root.container
                    }
                }
            }

            Loader {
                id: stickerLoader
                active: contentType === Constants.messageContentType.stickerType
                anchors.top: parent.top
                anchors.topMargin: active ? Style.current.halfPadding : 0
                sourceComponent: Component {
                    Rectangle {
                        id: stickerContainer
                        color: Style.current.transparent
                        border.color: isHovered ? Qt.darker(Style.current.border, 1.1) : Style.current.border
                        border.width: 1
                        radius: 16
                        width: stickerId.width + 2 * chatVerticalPadding
                        height: stickerId.height + 2 * chatVerticalPadding

                        StatusSticker {
                            id: stickerId
                            anchors.top: parent.top
                            anchors.topMargin: chatVerticalPadding
                            anchors.left: parent.left
                            anchors.leftMargin: chatVerticalPadding
                            contentType: root.contentType
                            stickerData: root.sticker
                            onLoaded: {
                                if(!root.messageStore)
                                    return
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
                messageContextMenuParent: root
                isHovered: root.isHovered
                isMessageActive: root.isMessageActive
                isActivityCenterMessage: activityCenterMessage
                stickersLoaded: root.stickersLoaded
                onClickMessage: {
                    root.clickMessage(isProfileClick, isSticker, isImage, null, false, false, false, false, "");
                }
                onOpenStickerPackPopup: {
                    root.openStickerPackPopup(root.stickerPack);
                }

                onSetMessageActive: {
                    setMessageActive(messageId, active);
                }
            }

            Loader {
                id: linksLoader
                active: !!linkUrls
                anchors.top: chatText.bottom
                anchors.topMargin: active ? Style.current.halfPadding : 0

                sourceComponent: Component {
                    LinksMessageView {
                        linkUrls: root.linkUrls
                        container: root.container
                        messageStore: root.messageStore
                        isCurrentUser: isCurrentUser
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
                active: contentType === Constants.messageContentType.transactionType
                anchors.top: parent.top
                anchors.topMargin: active ? (chatName.visible ? 4 : 6) : 0
                sourceComponent: Component {
                    TransactionBubbleView {
                        //store: rootStore
                        contactsStore: root.contactsStore
                    }
                }
            }

            Loader {
                active: contentType === Constants.messageContentType.communityInviteType
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: active ? 8 : 0
                sourceComponent: Component {
                    id: invitationBubble
                    InvitationBubbleView {
                        // Not Refactored Yet
//                        store: rootStore
                        communityId: root.container.communityId
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
            isCurrentUser: isCurrentUser
            isExpired: isExpired
            timeout: timeout
            onClicked: {
                // Not Refactored Yet
//                rootStore.chatsModelInst.messageView.resendMessage(chatId, messageId)
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
                 (forceHoverHandler || (typeof root.messageContextMenu !== "undefined" && typeof Global.profilePopupOpened !== "undefined" &&
                                        !root.messageContextMenu.opened && !Global.profilePopupOpened && !Global.popupOpened))
        onHoveredChanged: {
            setHovered(messageId, hovered);
        }
    }

    Loader {
        id: emojiReactionLoader
        active: reactionsModel.count > 0
        anchors.bottom: messageContainer.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.left: messageContainer.left
        anchors.leftMargin: messageContainer.messageContent.anchors.leftMargin

        sourceComponent: Component {
            EmojiReactionsPanel {
                id: emojiRect
                store: root.messageStore
                emojiReactionsModel: reactionsModel
                onHoverChanged: {
                    setHovered(messageId, hovered)
                }
                isMessageActive: isMessageActive
                isCurrentUser: isCurrentUser
                onAddEmojiClicked: {
                    root.addEmoji(false, false, false, null, true, false);
                    // Set parent, X & Y positions for the messageContextMenu
                    root.messageContextMenu.parent = emojiReactionLoader
                    root.messageContextMenu.setXPosition = function() { return (root.messageContextMenu.parent.x + 4)}
                    root.messageContextMenu.setYPosition = function() { return (-root.messageContextMenu.height - 4)}
                }

                onToggleReaction: {
                    if(!root.messageStore)
                    {
                        console.error("reaction cannot be toggled, message store is not valid")
                        return
                    }

                    root.messageStore.toggleReaction(messageId, emojiID)
                }

                onSetMessageActive: {
                    setMessageActive(messageId, active);;
                }
            }
        }
    }
}
