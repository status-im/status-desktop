import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.panels.chat 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1

Item {
    id: root

    property var store
    property var messageStore
    property var usersStore
    property var contactsStore

    property var emojiPopup

    property var messageContextMenu
    property var container
    property int contentType
    property bool isChatBlocked: false
    property bool isActiveChannel: false
    property int senderTrustStatus

    property int chatHorizontalPadding: Style.current.halfPadding
    property int chatVerticalPadding: 7
    property bool headerRepeatCondition: (authorCurrentMsg !== authorPrevMsg ||
                                          shouldRepeatHeader || dateGroupLbl.visible || chatReply.active)
    property bool stickersLoaded: false
    property string sticker
    property int stickerPack
    property bool isMessageActive: false
    property bool amISender: false
    property string senderIcon: ""
    property bool isHovered: false
    property bool isInPinnedPopup: false
    property bool pinnedMessage: false
    property bool canPin: false
    property string communityId
    property bool editModeOn: false
    property string linkUrls: ""

    property string message: ""

    property var transactionParams

    signal openStickerPackPopup(string stickerPackId)
    signal addEmoji(bool isProfileClick, bool isSticker, bool isImage , var image, bool isEmoji, bool hideEmojiPicker)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool isEmoji, bool hideEmojiPicker, bool isReply, bool isRightClickOnImage, string imageSource)
    signal replyClicked(string messageId, string author)
    signal imageClicked(var image)


    function setMessageActive(messageId, active) {
        if (active) {
            activeMessage = messageId;
        } else if (activeMessage === messageId) {
            activeMessage = "";
        }
    }


    width: parent.width
    height: messageContainer.height + messageContainer.anchors.topMargin
            + (dateGroupLbl.visible ? dateGroupLbl.height + dateGroupLbl.anchors.topMargin : 0)

    Connections {
        target: !!root.messageStore && root.messageStore.messageModule ?
            root.messageStore.messageModule : null
        enabled: !!root.messageStore && !!root.messageStore.messageModule && responseTo !== ""
        onRefreshAMessageUserRespondedTo: {
            if(msgId === messageId)
                chatReply.resetOriginalMessage()
        }
    }

    Timer {
        id: ensureMessageFullyVisibleTimer
        interval: 1
        onTriggered: {
            chatLogView.positionViewAtIndex(ListView.currentIndex, ListView.Contain)
        }
    }

    MessageMouseArea {
        enabled: !root.isChatBlocked && !placeholderMessage && !isImage
        anchors.fill: messageContainer
        acceptedButtons: activityCenterMessage ? Qt.LeftButton : Qt.RightButton
        messageContextMenu: root.messageContextMenu
        messageContextMenuParent: root
        isHovered: root.isHovered
        isMessageActive: root.isMessageActive
        isActivityCenterMessage: activityCenterMessage
        stickersLoaded: root.stickersLoaded
        onClickMessage: {
            root.clickMessage(isProfileClick, isSticker, isImage, null, isEmoji, false, false, false, "");
        }
    }

    ChatButtonsPanel {
        contentType: messageContentType
        parentIsHovered: !editModeOn && isHovered
        isChatBlocked: root.isChatBlocked
        onHoverChanged: {
            hovered && setHovered(messageId, hovered)
        }
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: messageContainer.top
        // This is not exactly like the design because the hover becomes messed up with the buttons on top of another Message
        anchors.topMargin: -Style.current.halfPadding
        messageContextMenu: root.messageContextMenu
        isInPinnedPopup: root.isInPinnedPopup
        fromAuthor: senderId
        editBtnActive: isText && !editModeOn && root.amISender
        pinButtonActive: {
            if (!root.messageStore)
                 return false

            const chatType = root.messageStore.getChatType();
            const amIChatAdmin = root.messageStore.amIChatAdmin();
            const pinMessageAllowedForMembers = root.messageStore.pinMessageAllowedForMembers()

            return chatType === Constants.chatType.oneToOne ||
                   chatType === Constants.chatType.privateGroupChat && amIChatAdmin ||
                   chatType === Constants.chatType.communityChat && (amIChatAdmin || pinMessageAllowedForMembers);

        }
        deleteButtonActive: {
            if (!root.messageStore)
                return false;
            const isMyMessage = senderId !== "" && senderId === userProfile.pubKey;
            const chatType = root.messageStore.getChatType();
            return isMyMessage &&
                    (contentType === Constants.messageContentType.messageType ||
                     contentType === Constants.messageContentType.stickerType ||
                     contentType === Constants.messageContentType.emojiType ||
                     contentType === Constants.messageContentType.imageType ||
                     contentType === Constants.messageContentType.audioType);
        }
        pinnedMessage: root.pinnedMessage
        canPin: root.canPin

        activityCenterMsg: activityCenterMessage
        placeholderMsg: placeholderMessage
        onClickMessage: {
            root.clickMessage(isProfileClick, isSticker, isImage, image, isEmoji, hideEmojiPicker, false, false, "");
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
                onClosed: root.setMessageActive(messageId, false)
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
                + (!chatName.visible ? 6 : 0)
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
                        text: qsTr("Pinned by %1").arg(Utils.getContactDetailsAsJson(messagePinnedBy).displayName)
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
            isCurrentUser: root.amISender
            longReply: active && textFieldImplicitWidth > width
            container: root.container
            chatHorizontalPadding: chatHorizontalPadding
            active: responseTo !== "" && !activityCenterMessage

            function resetOriginalMessage() {
                if(!root.messageStore)
                    return
                let obj = root.messageStore.getMessageByIdAsJson(responseTo)
                if(!obj)
                    return

                amISenderOfTheRepliedMessage = obj.amISender
                repliedMessageContentType = obj.contentType
                repliedMessageSenderIcon = obj.senderIcon
                // TODO: not sure about is edited at the moment
                repliedMessageIsEdited = false
                repliedMessageSender = obj.senderDisplayName
                repliedMessageSenderPubkey = obj.senderId
                repliedMessageSenderIsAdded = obj.senderIsAdded
                repliedMessageContent = obj.messageText
                repliedMessageImage = obj.messageImage
                stickerData = obj.sticker
            }

            Component.onCompleted: {
                resetOriginalMessage()
            }

            onScrollToBottom: {
                // Not Refactored Yet
//                messageStore.scrollToBottom(isit, root.container);
            }

            onClickMessage: {
                root.clickMessage(isProfileClick, isSticker, isImage, image, isEmoji, hideEmojiPicker, isReply, false, "")
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

            image: root.senderIcon
            pubkey: senderId
            name: senderDisplayName

            onClicked: root.clickMessage(true, false, false, null, false, false, false, false, "")
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
            amISender: root.amISender
            onClickMessage: {
                root.clickMessage(true, false, false, null, false, false, false, false, "")
            }
        }

        VerificationLabel {
            id: trustStatus
            anchors.left: chatName.right
            anchors.leftMargin: 4
            anchors.bottom: chatName.bottom
            anchors.bottomMargin: 4
            visible: !root.amISender && chatName.visible
            trustStatus: senderTrustStatus
        }

        ChatTimePanel {
            id: chatTime
            visible: !editModeOn && headerRepeatCondition
            anchors.verticalCenter: chatName.verticalCenter
            anchors.left: trustStatus.right
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

                    store: root.store
                    usersStore: root.usersStore

                    chatInputPlaceholder: qsTr("Pinned by %1")
                    chatType: messageStore.getChatType()
                    isEdit: true
                    emojiPopup: root.emojiPopup
                    messageContextMenu: root.messageContextMenu
                    onSendMessage: {
                        saveBtn.clicked(null)
                    }
                    suggestions.onVisibleChanged: {
                        if (suggestions.visible) {
                            editText.suggestionsOpened = true
                        }
                    }

                    Component.onCompleted: {
                        let mentionsMap = new Map()
                        let index = 0
                        while (true) {
                            index = message.indexOf("<a href=", index)
                            if (index < 0) {
                                break
                            }
                            let startIndex = index
                            let endIndex = message.indexOf("</a>", index) + 4
                            if (endIndex < 0) {
                                index += 8 // "<a href="
                                continue
                            }
                            let addrIndex = message.indexOf("0x", index + 8)
                            if (addrIndex < 0) {
                                index += 8 // "<a href="
                                continue
                            }
                            let addrEndIndex = message.indexOf("\"", addrIndex)
                            if (addrEndIndex < 0) {
                                index += 8 // "<a href="
                                continue
                            }
                            const mentionLink = message.substring(startIndex, endIndex)
                            const linkTag = message.substring(index, endIndex)
                            const linkText = linkTag.replace(/(<([^>]+)>)/ig,"").trim()
                            const atSymbol = linkText.startsWith("@") ? '' : '@'
                            const mentionTag = Constants.mentionSpanTag + atSymbol + linkText + '</span> '
                            mentionsMap.set(mentionLink, mentionTag)
                            index += linkTag.length
                        }

                        var text = message
                        for (let [key, value] of mentionsMap) {
                            text = text.replace(new RegExp(key, 'g'), value)
                        }
                        editTextInput.textInput.text = text
                        editTextInput.textInput.cursorPosition = editTextInput.textInput.length
                    }
                }

                StatusQControls.StatusFlatButton {
                    id: cancelBtn
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.halfPadding
                    anchors.top: editTextInput.bottom
                    text: qsTr("Cancel")
                    onClicked: {
                        messageStore.setEditModeOff(messageId)
                        editTextInput.textInput.text = StatusQUtils.Emoji.parse(message)
                        ensureMessageFullyVisibleTimer.start()
                    }
                }

                StatusQControls.StatusButton {
                    id: saveBtn
                    anchors.left: cancelBtn.right
                    anchors.leftMargin: Style.current.halfPadding
                    anchors.top: editTextInput.bottom
                    text: qsTr("Save")
                    enabled: editTextInput.textInput.text.trim().length > 0
                    onClicked: {
                        let msg = rootStore.plainText(StatusQUtils.Emoji.deparse(editTextInput.textInput.text))
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
            anchors.topMargin: (!chatName.visible || !chatReply.active  || !pinnedRectangleLoader.active) ? 4 : 0
            visible: !editModeOn
            ChatTextView {
                id: chatText
                readonly property int leftPadding: chatImage.anchors.leftMargin + chatImage.width + chatHorizontalPadding
                visible: isText || isEmoji || (isImage && root.message !== "<p>Update to latest version to see a nice image here!</p>")

                message: Utils.removeGifUrls(root.message)
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
                anchors.top: chatText.visible ? chatText.bottom : parent.top
                anchors.topMargin: active ? 6 : 0
                z: 51
                sourceComponent: Component {
                    StatusChatImage {
                        playing: root.messageStore.playAnimation
                        imageSource: messageImage
                        imageWidth: 200
                        isActiveChannel: root.isActiveChannel
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
                                // Not refactored yet
                                // root.messageStore.scrollToBottom(true, root.container)
                            }
                        }
                    }
                }
            }

            MessageMouseArea {
                id: messageMouseArea
                anchors.fill: stickerLoader.active ? stickerLoader : chatText
                z: activityCenterMessage ? chatText.z + 1 : chatText.z -1
                enabled: !root.isChatBlocked && !placeholderMessage
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
                    root.setMessageActive(messageId, active);
                }
            }

            Loader {
                id: linksLoader
                active: !!linkUrls
                height: item ? item.height : 0
                anchors.top: chatText.bottom
                anchors.topMargin: active ? Style.current.halfPadding : 0

                sourceComponent: Component {
                    LinksMessageView {
                        linkUrls: root.linkUrls
                        container: root.container
                        messageStore: root.messageStore
                        store: root.store
                        isCurrentUser: root.amISender
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
                        transactionParams: root.transactionParams
                        store: root.store
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
                        store: root.store
                        communityId: root.communityId
                    }
                }
            }
        }


        Retry {
            id: retry
            height: visible ? implicitHeight : 0
            anchors.left: chatTime.visible ? chatTime.right : messageContent.left
            anchors.leftMargin: chatTime.visible ? chatHorizontalPadding : 0
            anchors.top: chatTime.visible ? chatTime.top : messageContent.bottom
            anchors.topMargin: chatTime.visible ? 0 : -4
            anchors.bottom: chatTime.visible ? chatTime.bottom : undefined
            isCurrentUser: root.amISender
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
                isCurrentUser: root.amISender
                onAddEmojiClicked: {
                    if(root.isChatBlocked)
                        return

                    // First set parent, X & Y positions for the messageContextMenu
                    root.messageContextMenu.parent = emojiRect
                    root.messageContextMenu.setXPosition = function() { return (root.messageContextMenu.parent.x + root.messageContextMenu.parent.width + 4) }
                    root.messageContextMenu.setYPosition = function() { return  (-root.messageContextMenu.height - 4) }

                    // Second, add emoji that also triggers setXYPosition methods / open popup:
                    root.addEmoji(false, false, false, null, true, false);
                }

                onToggleReaction: {
                    if(root.isChatBlocked)
                        return

                    if(!root.messageStore)
                    {
                        console.error("reaction cannot be toggled, message store is not valid")
                        return
                    }

                    root.messageStore.toggleReaction(messageId, emojiID)
                }

                onSetMessageActive: {
                    root.setMessageActive(messageId, active);
                }
            }
        }
    }
}
