import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml.Models 2.13
import QtQuick.Layouts 1.13
import SortFilterProxyModel 0.2
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "../Chat/data"
import "../Chat/ChatColumn"
import "../Chat/components"

ScrollView {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: chatLogView.contentHeight + 140
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    
    property var onActivated: function () {
        chatsModel.setActiveChannelToTimeline()
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
        popup.openPopup(profileModel.profile.pubKey !== fromAuthorParam, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam);
    }


    MessageContextMenu {
        id: messageContextMenu
    }

    StatusImageModal {
        id: imagePopup
    }

    EmojiReactions {
        id: reactionModel
    }

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        height: 450
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
                        chatsModel.sendImage(url, true);
                    })
                }
                var msg = chatsModel.plainText(Emoji.deparse(statusUpdateInput.textInput.text))
                if (msg.length > 0){
                    msg = statusUpdateInput.interpretMessage(msg)
                    chatsModel.sendMessage(msg, "", Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType, true, "");
                    statusUpdateInput.textInput.text = "";
                    if(event) event.accepted = true
                    sendMessageSound.stop()
                    Qt.callLater(sendMessageSound.play);
                }
            }
        }

        EmptyTimeline {
            id: emptyTimeline
            anchors.top: statusUpdateInput.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            visible: chatsModel.messageList.rowCount() === 0
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

            model: messageProxyModel
            section.property: "sectionIdentifier"
            section.criteria: ViewSection.FullString

            delegate: Message {
                id: msgDelegate
                fromAuthor: model.fromAuthor
                chatId: model.chatId
                userName: model.userName
                localName: model.localName
                alias: model.alias
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
                // This is used in order to have access to the previous message and determine the timestamp
                // we can't rely on the index because the sequence of messages is not ordered on the nim side
                prevMessageIndex: msgDelegate.DelegateModel.itemsIndex < messageProxyModel.count - 1 ? msgDelegate.DelegateModel.itemsIndex + 1 : -1;
                prevMsgTimestamp: prevMessageIndex > -1 ? messageProxyModel.get(prevMessageIndex).timestamp : ""
                nextMessageIndex: msgDelegate.DelegateModel.itemsIndex <= 1 ? -1 :  msgDelegate.DelegateModel.itemsIndex - 1;
                nextMsgTimestamp: nextMessageIndex > -1 ? messageProxyModel.get(nextMessageIndex).timestamp : ""
                
                timeout: model.timeout
            }
        }

        SortFilterProxyModel {
            id: messageProxyModel
            sourceModel: chatsModel.messageList
            sorters: ExpressionSorter {
                expression: {
                    return modelLeft.clock > modelRight.clock;
                }
            }
        }

    }
}
