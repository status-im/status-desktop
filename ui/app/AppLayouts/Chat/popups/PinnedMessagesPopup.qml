import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.views.chat 1.0

StatusDialog {
    id: root

    property var store
    property var messageStore
    property var pinnedMessagesModel //this doesn't belong to the messageStore, it is a part of the ChatContentStore, but we didn't introduce it yet.
    property string messageToPin
    property string messageToUnpin
    property var emojiReactionsModel

    width: 800
    height: 428
    padding: 0

    title: root.messageToPin ? qsTr("Pin limit reached") : qsTr("Pinned messages")

    header: StatusDialogHeader {
        visible: root.title
        headline.title: root.title
        headline.subtitle: root.messageToPin ? qsTr("Unpin a previous message first")
                                              : qsTr("%n message(s)", "", pinnedMessageListView.count)
        actions.closeButton.onClicked: root.close()
    }

    contentItem: ColumnLayout {
        StatusBaseText {
            visible: pinnedMessageListView.count === 0
            text: qsTr("Pinned messages will appear here.")
            Layout.alignment: Qt.AlignCenter
            verticalAlignment: Text.AlignVCenter
            color: Style.current.secondaryText
        }

        ButtonGroup {
            id: pinButtonGroup
        }

        StatusListView {
            id: pinnedMessageListView
            model: root.pinnedMessagesModel
            Layout.fillWidth: true
            Layout.fillHeight: count

            delegate: Item {
                id: messageDelegate

                width: ListView.view.width
                height: messageItem.height

                MessageView {
                    id: messageItem

                    width: parent.width

                    rootStore: root.store
                    messageStore: root.messageStore
                    messageContextMenu: msgContextMenu

                    messageId: model.id
                    responseToMessageWithId: model.responseToMessageWithId
                    senderId: model.senderId
                    senderDisplayName: model.senderDisplayName
                    senderOptionalName: model.senderOptionalName
                    senderIsEnsVerified: model.senderEnsVerified
                    senderIsAdded: model.senderIsAdded
                    senderIcon: model.senderIcon
                    senderTrustStatus: model.senderTrustStatus
                    amISender: model.amISender
                    messageText: model.messageText
                    messageImage: model.messageImage
                    messageTimestamp: model.timestamp
                    messageOutgoingStatus: model.outgoingStatus
                    messageContentType: model.contentType
                    pinnedMessage: model.pinned
                    messagePinnedBy: model.pinnedBy
                    linkUrls: model.links
                    transactionParams: model.transactionParameters

                    // This is possible since we have all data loaded before we load qml.
                    // When we fetch messages to fulfill a gap we have to set them at once.
                    prevMessageIndex: index - 1
                    prevMessageAsJsonObj: root.messageStore? root.messageStore.getMessageByIndexAsJson(index - 1) : {}
                    nextMessageIndex: index + 1
                    nextMessageAsJsonObj: root.messageStore? root.messageStore.getMessageByIndexAsJson(index + 1) : {}

                    // Additional params
                    isInPinnedPopup: true
                    disableHover: !!root.messageToPin
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !!root.messageToPin
                    cursorShape: Qt.PointingHandCursor
                    z: 55
                    onClicked: {
                        if (!radio.checked)
                            radio.checked = true
                    }
                }

                StatusRadioButton {
                    id: radio
                    visible: !!root.messageToPin
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.bigPadding
                    anchors.verticalCenter: parent.verticalCenter
                    ButtonGroup.group: pinButtonGroup
                    onCheckedChanged: { // NB this should be `onToggled` but MouseArea above handles the whole delegate
                        root.messageToUnpin = checked ? model.id : ""
                    }
                }
            }
        }

        MessageContextMenuView {
            id: msgContextMenu
            reactionModel: root.emojiReactionsModel
            store: root.store
            pinnedPopup: true
            pinnedMessage: true
            onShouldCloseParentPopup: {
                root.close()
            }

            onUnpinMessage: {
                root.messageStore.unpinMessage(messageId)
            }

            onJumpToMessage: {
                root.messageStore.messagesModule.jumpToMessage(messageId)
            }
        }
    }

    footer: StatusDialogFooter {
        id: footer
        visible: !!root.messageToPin
        rightButtons: ObjectModel {
            StatusButton {
                visible: footer.visible
                enabled: !!root.messageToUnpin && pinButtonGroup.checkedButton
                text: qsTr("Unpin selected message and pin new message")
                onClicked: {
                    root.messageStore.unpinMessage(root.messageToUnpin)
                    root.messageToUnpin = ""
                    root.messageStore.pinMessage(root.messageToPin)
                    root.messageToPin = ""
                    root.close()
                }
            }
        }
    }
}
