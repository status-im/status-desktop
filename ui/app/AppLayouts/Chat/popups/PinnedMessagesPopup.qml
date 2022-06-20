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
    id: popup

    property var store
    property var messageStore
    property var pinnedMessagesModel //this doesn't belong to the messageStore, it is a part of the ChatContentStore, but we didn't introduce it yet.
    property string messageToPin
    property string messageToUnpin
    property var emojiReactionsModel

    header: Item {
        height: childrenRect.height
        width: parent.width

        StyledText {
            id: title
            //% "Pin limit reached"
            text: !!popup.messageToPin ? qsTrId("pin-limit-reached") :
                                               //% "Pinned messages"
                                               qsTrId("pinned-messages")
            anchors.top: parent.top
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: Style.dp(17)
        }

        StyledText {
            property int nbMessages: pinnedMessageListView.count

            id: nbPinnedMessages
            text: {
                if (!!popup.messageToPin) {
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
            anchors.topMargin: Style.dp(2)
            font.pixelSize: Style.current.primaryTextFontSize
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
            model: popup.pinnedMessagesModel
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
                    store: popup.store
                    messageStore: popup.messageStore
                    messageContextMenu: msgContextMenu

                    messageId: model.id
                    responseToMessageWithId: model.responseToMessageWithId
                    senderId: model.senderId
                    senderDisplayName: model.senderDisplayName
                    senderLocalName: model.senderLocalName
                    senderIcon: model.senderIcon
                    amISender: model.amISender
                    message: model.messageText
                    messageImage: model.messageImage
                    messageTimestamp: model.timestamp
                    messageOutgoingStatus: model.outgoingStatus
                    messageContentType: model.contentType
                    pinnedMessage: model.pinned
                    messagePinnedBy: model.pinnedBy
                    reactionsModel: model.reactions
                    linkUrls: model.links
                    isInPinnedPopup: true
                    transactionParams: model.transactionParameters

                    // This is possible since we have all data loaded before we load qml.
                    // When we fetch messages to fulfill a gap we have to set them at once.
                    prevMessageIndex: index - 1
                    prevMessageAsJsonObj: popup.messageStore? popup.messageStore.getMessageByIndexAsJson(index - 1) : {}
                    nextMessageIndex: index + 1
                    nextMessageAsJsonObj: popup.messageStore? popup.messageStore.getMessageByIndexAsJson(index + 1) : {}

                    // Additional params
                    forceHoverHandler: !popup.messageToPin
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !!popup.messageToPin
                    cursorShape: Qt.PointingHandCursor
                    z: 55
                    onClicked: radio.toggle()
                }

                StatusQControls.StatusRadioButton {
                    id: radio
                    visible: !!popup.messageToPin
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    ButtonGroup.group: pinButtonGroup
                    function toggle() {
                        radio.checked = !radio.checked
                        if (radio.checked) {
                            popup.messageToUnpin = model.id
                        }
                    }
                }
            }
        }
        MessageContextMenuView {
            id: msgContextMenu
            reactionModel: popup.emojiReactionsModel
            store: popup.store
            pinnedPopup: true
            pinnedMessage: true
            onShouldCloseParentPopup: {
                popup.close()
            }

            onPinMessage: {
                popup.messageStore.pinMessage(messageId)
            }

            onUnpinMessage: {
                popup.messageStore.unpinMessage(messageId)
            }

            onToggleReaction: {
                popup.messageStore.toggleReaction(messageId, emojiId)
            }

            onOpenProfileClicked: {
                Global.openProfilePopup(publicKey, null, state)
            }
        }
    }


    footer: Item {
        width: parent.width
        height: btnUnpin.height

        StatusQControls.StatusButton {
            id: btnUnpin
            visible: !!popup.messageToPin
            enabled: !!popup.messageToUnpin
            //% "Unpin"
            text: qsTrId("unpin")
            type: StatusQControls.StatusBaseButton.Type.Danger
            anchors.right: parent.right
            onClicked: {
                popup.messageStore.unpinMessage(popup.messageToUnpin)
                popup.messageToUnpin = ""
                popup.messageStore.pinMessage(popup.messageToPin)
                popup.messageToPin = ""
                popup.close()
            }
        }
    }
}
