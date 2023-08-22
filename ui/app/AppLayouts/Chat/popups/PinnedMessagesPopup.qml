import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14
import QtGraphicalEffects 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
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
    property string chatId

    readonly property var contactDetails: store ? store.oneToOneChatContact : null
    readonly property bool isPinActionAvaliable: contactDetails ? contactDetails.isContact : true

    width: 800
    height: 428
    padding: 0

    title: root.messageToPin ? qsTr("Pin limit reached") : qsTr("Pinned messages")
    subtitle: root.messageToPin ? qsTr("Unpin a previous message first")
                                : qsTr("%n message(s)", "", pinnedMessageListView.count)

    QtObject {
        id: d

        function jumpToMessage(messageId) {
            root.close()
            root.messageStore.messageModule.jumpToMessage(messageId)
        }
    }

    contentItem: ColumnLayout {
        id: column

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

                    messageId: model.id
                    responseToMessageWithId: model.responseToMessageWithId
                    senderId: model.senderId
                    senderDisplayName: model.senderDisplayName
                    senderOptionalName: model.senderOptionalName
                    senderIsEnsVerified: model.senderEnsVerified
                    senderIsAdded: model.senderIsAdded
                    senderIcon: model.senderIcon
                    senderColorHash: model.senderColorHash
                    senderTrustStatus: model.senderTrustStatus
                    amISender: model.amISender
                    messageText: model.messageText
                    messageImage: model.messageImage
                    messageTimestamp: model.timestamp
                    messageOutgoingStatus: model.outgoingStatus
                    messageContentType: model.contentType
                    pinnedMessage: model.pinned
                    messagePinnedBy: model.pinnedBy
                    sticker: model.sticker
                    stickerPack: model.stickerPack
                    linkPreviewModel: model.linkPreviewModel
                    links: model.links
                    transactionParams: model.transactionParameters
                    quotedMessageText: model.quotedMessageParsedText
                    quotedMessageFrom: model.quotedMessageFrom
                    quotedMessageContentType: model.quotedMessageContentType
                    quotedMessageDeleted: model.quotedMessageDeleted
                    quotedMessageAuthorDetailsName: model.quotedMessageAuthorName
                    quotedMessageAuthorDetailsDisplayName: model.quotedMessageAuthorDisplayName
                    quotedMessageAuthorDetailsThumbnailImage: model.quotedMessageAuthorThumbnailImage
                    quotedMessageAuthorDetailsEnsVerified: model.quotedMessageAuthorEnsVerified
                    quotedMessageAuthorDetailsIsContact: model.quotedMessageAuthorIsContact
                    quotedMessageAuthorDetailsColorHash: model.quotedMessageAuthorColorHash

                    // This is possible since we have all data loaded before we load qml.
                    // When we fetch messages to fulfill a gap we have to set them at once.
                    prevMessageIndex: index - 1
                    prevMessageAsJsonObj: root.messageStore ? root.messageStore.getMessageByIndexAsJson(index - 1) : {}
                    nextMessageIndex: index + 1
                    nextMessageAsJsonObj: root.messageStore ? root.messageStore.getMessageByIndexAsJson(index + 1) : {}

                    // Additional params
                    isInPinnedPopup: true
                    shouldRepeatHeader: true
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: 55
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                                   switch (mouse.button) {
                                       case Qt.RightButton:
                                           Global.openMenu(pinnedPopupMessageContextMenuComponent, this, {
                                                               messageId: messageItem.messageId,
                                                           })
                                           break
                                       case Qt.LeftButton:
                                           if (!!root.messageToPin) {
                                               if (!radio.checked)
                                                radio.checked = true
                                           } else {
                                               d.jumpToMessage(model.id)
                                           }
                                           break
                                   }
                    }
                }

                StatusFlatRoundButton {
                    id: unpinButton
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.bigPadding
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.bigPadding
                    z: mouseArea.z + 1
                    width: 32
                    height: 32
                    visible: root.isPinActionAvaliable && !root.messageToPin && (hovered || mouseArea.containsMouse)
                    icon.name: "unpin"
                    tooltip.text: qsTr("Unpin")
                    color: hovered ? Theme.palette.primaryColor2 : Theme.palette.indirectColor1
                    onClicked: {
                        root.messageStore.unpinMessage(model.id)
                    }
                }

                StatusRadioButton {
                    id: radio
                    visible: root.messageToPin
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.bigPadding
                    anchors.verticalCenter: parent.verticalCenter
                    ButtonGroup.group: pinButtonGroup
                    onCheckedChanged: { // NB this should be `onToggled` but MouseArea above handles the whole delegate
                        root.messageToUnpin = checked ? model.id : ""
                    }
                }

                Component {
                    id: pinnedPopupMessageContextMenuComponent

                    StatusMenu {
                        id: messageContextMenu

                        property string messageId

                        StatusAction {
                            text: qsTr("Unpin")
                            icon.name: "unpin"
                            onTriggered: {
                                root.messageStore.unpinMessage(messageContextMenu.messageId)
                                close()
                            }
                        }

                        StatusAction {
                            text: qsTr("Jump to")
                            icon.name: "arrow-up"
                            onTriggered: {
                                d.jumpToMessage(messageContextMenu.messageId)
                                close()
                            }
                        }

                        onOpened: {
                            messageItem.setMessageActive(model.id, true)
                        }
                        onClosed: {
                            messageItem.setMessageActive(model.id, false)
                            destroy()
                        }
                    }
                }
            }
        }

        layer.enabled: root.visible && !root.messageToPin
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: column.width
                height: column.height
                radius: background.radius

                Rectangle {
                    width: parent.width
                    height: parent.radius
                    anchors.top: parent.top
                }
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
