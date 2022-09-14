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
        width: ListView.view.width

        audioMessageInfoText: "Audio Message"
        cancelButtonText: "Cancel"
        saveButtonText: "Save"
        loadingImageText: "Loading image..."
        errorLoadingImageText: "Error loading the image"
        resendText: "Resend"
        pinnedMsgInfoText: "Pinned by"

        timestamp: model.timestamp
        isAReply: model.isReply
        hasMention: model.hasMention
        isPinned: model.isPinned
        pinnedBy: model.pinnedBy
        hasExpired: model.hasExpired
        reactionsModel: model.reactions || []

        messageDetails: StatusMessageDetails {
            contentType: model.contentType
            messageContent: model.messageContent
            amISender: model.amIsender
            sender.id: model.senderId
            sender.displayName: model.senderDisplayName
            sender.secondaryName: model.senderOptionalName
            sender.isContact: model.isContact
            sender.trustIndicator: model.trustIndicator
            sender.profileImage: StatusProfileImageSettings {
                width: 40
                height: 40
                pubkey: model.senderId
                name: model.profileImage || ""
                colorId: 1
                colorHash: ListModel {
                    ListElement { colorId: 13; segmentLength: 5 }
                    ListElement { colorId: 31; segmentLength: 5 }
                    ListElement { colorId: 10; segmentLength: 1 }
                    ListElement { colorId: 2; segmentLength: 5 }
                    ListElement { colorId: 26; segmentLength: 2 }
                    ListElement { colorId: 19; segmentLength: 4 }
                    ListElement { colorId: 28; segmentLength: 3 }
                }
            }

            messageText: model.message
        }

        replyDetails: StatusMessageDetails {
            amISender:  model.isReply && model.replyAmISender
            sender.id: model.replySenderId || ""
            sender.displayName:  model.isReply ? model.replySenderName: ""
            sender.secondaryName: model.isReply ? model.replySenderEnsName : ""
            sender.profileImage: StatusProfileImageSettings {
                width: 20
                height: 20
                name: model.isReply ? model.replyProfileImage: ""
                pubkey: model.replySenderId
                colorId: 1
                colorHash: ListModel {
                    ListElement { colorId: 13; segmentLength: 5 }
                    ListElement { colorId: 31; segmentLength: 5 }
                    ListElement { colorId: 10; segmentLength: 1 }
                    ListElement { colorId: 2; segmentLength: 5 }
                    ListElement { colorId: 26; segmentLength: 2 }
                    ListElement { colorId: 19; segmentLength: 4 }
                    ListElement { colorId: 28; segmentLength: 3 }
                }
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
