import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ListView {
    id: messageList
    anchors.fill: parent
    anchors.margins: 15
    clip: true
    delegate: StatusMessage {
        id: delegate
        width: parent.width

        audioMessageInfoText: "Audio Message"
        cancelButtonText: "Cancel"
        saveButtonText: "Save"
        loadingImageText: "Loading image..."
        errorLoadingImageText: "Error loading the image"
        resendText: "Resend"
        pinnedMsgInfoText: "Pinned by"

        messageDetails: StatusMessageDetails {
            contentType: model.contentType
            messageContent: model.messageContent
            amISender: model.amIsender
            displayName: model.userName
            secondaryName: model.localName !== "" && model.ensName.startsWith("@") ? model.ensName: ""
            chatID: model.chatKey
            profileImage: StatusImageSettings {
                width: 40
                height: 40
                source: model.profileImage
                isIdenticon: model.isIdenticon
            }
            messageText: model.message
            hasMention: model.hasMention
            contactType: model.contactType
            isPinned: model.isPinned
            pinnedBy: model.pinnedBy
            hasExpired: model.hasExpired
        }
        timestamp.text: "10:00 am"
        timestamp.tooltip.text: "10:01 am"
        // reply related data
        isAReply: model.isReply
        replyDetails: StatusMessageDetails {
            amISender:  model.isReply ? model.replyAmISender : ""
            displayName:  model.isReply ? model.replySenderName: ""
            profileImage: StatusImageSettings {
                width: 20
                height: 20
                source:  model.isReply ? model.replyProfileImage: ""
                isIdenticon:  model.isReply ? model.replyIsIdenticon: ""
            }
            messageText:  model.isReply ? model.replyMessageText: ""
            contentType: model.replyContentType
            messageContent: model.replyMessageContent
        }
        quickActions: [
            StatusFlatRoundButton {
                id: emojiBtn
                width: 32
                height: 32
                icon.name: "reaction-b"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: "Add reaction"
            },
            StatusFlatRoundButton {
                id: replyBtn
                width: 32
                height: 32
                icon.name: "reply"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: "Reply"
            },
            StatusFlatRoundButton {
                width: 32
                height: 32
                icon.name: "tiny/edit"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: "Edit"
                onClicked: {
                    delegate.editMode = !delegate.editMode
                }
            },
            StatusFlatRoundButton {
                id: otherBtn
                width: 32
                height: 32
                icon.name: "more"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: "More"
            }
        ]
    }
}
