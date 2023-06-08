import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import "./private/statusMessage"

Control {
    id: root

    enum ContentType {
        Unknown = 0,
        Text = 1,
        Emoji = 2,
        Image = 3,
        Sticker = 4,
        Audio = 5,
        Transaction = 6,
        Invitation = 7,
        DiscordMessage = 8,
        SystemMessagePinnedMessage = 14,
        SystemMessageMutualStateUpdate = 15
    }

    property list<Item> quickActions
    property var statusChatInput
    property alias linksComponent: linksLoader.sourceComponent
    property alias transcationComponent: transactionBubbleLoader.sourceComponent
    property alias invitationComponent: invitationBubbleLoader.sourceComponent
    property alias mouseArea: mouseArea

    property string pinnedMsgInfoText: ""

    property string messageAttachments: ""
    property var reactionIcons: []

    property string messageId: ""
    property bool editMode: false
    property bool isAReply: false
    property bool isEdited: false

    property bool hasMention: false
    property bool isPinned: false
    property string pinnedBy: ""
    property bool hasExpired: false
    property bool isSending: false
    property string resendError: ""
    property double timestamp: 0
    property var reactionsModel: []
    property bool hasLinks

    property bool showHeader: true
    property bool isActiveMessage: false
    property bool disableHover: false
    property bool disableEmojis: false
    property color overrideBackgroundColor: "transparent"
    property bool overrideBackground: false
    property bool profileClickable: true
    property bool hideMessage: false
    property bool isInPinnedPopup

    property StatusMessageDetails messageDetails: StatusMessageDetails {}
    property StatusMessageDetails replyDetails: StatusMessageDetails {}

    signal clicked(var sender, var mouse)
    signal profilePictureClicked(var sender, var mouse)
    signal senderNameClicked(var sender, var mouse)
    signal replyProfileClicked(var sender, var mouse)
    signal replyMessageClicked(var mouse)

    signal addReactionClicked(var sender, var mouse)
    signal toggleReactionClicked(int emojiId)
    signal imageClicked(var image, var mouse, var imageSource)
    signal stickerClicked()
    signal resendClicked()

    signal editCompleted(string newMsgText)
    signal editCancelled()
    signal stickerLoaded()
    signal linkActivated(string link)

    signal hoverChanged(string messageId, bool hovered)
    signal activeChanged(string messageId, bool active)

    function startMessageFoundAnimation() {
        messageFoundAnimation.start();
    }

    onMessageAttachmentsChanged: {
        root.prepareAttachmentsModel()
    }

    function prepareAttachmentsModel() {
        attachmentsModel.clear()
        if (!root.messageAttachments) {
            return
        }
        root.messageAttachments.split(" ").forEach(source => {
            attachmentsModel.append({source})
        })
    }

    hoverEnabled: (!root.isActiveMessage && !root.disableHover)
    background: Rectangle {
        color: {
            if (root.overrideBackground)
                return root.overrideBackgroundColor;

            if (root.editMode)
                return Theme.palette.baseColor2;

            if (root.hovered || root.isActiveMessage) {
                if (root.hasMention)
                    return Theme.palette.mentionColor3;
                if (root.isPinned)
                    return Theme.palette.pinColor2;
                return Theme.palette.baseColor2;
            }

            if (root.hasMention)
                return Theme.palette.mentionColor4;
            if (root.isPinned)
                return Theme.palette.pinColor3;
            return "transparent";
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
            anchors.fill: parent
            opacity: 0
            visible: opacity > 0.001
            color: Theme.palette.messageHighlightColor
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: 2
            visible: root.isPinned || root.hasMention
            color: root.hasMention ? Theme.palette.mentionColor1 : root.isPinned ? Theme.palette.pinColor1
                                                                                 : "transparent" // not visible really
        }
    }

    contentItem: Item {

        implicitWidth: messageLayout.implicitWidth
        implicitHeight: messageLayout.implicitHeight

        MouseArea {
            id: mouseArea
            anchors.fill: parent
        }

        ColumnLayout {
            id: messageLayout
            anchors.fill: parent
            spacing: 2

            Loader {
                Layout.fillWidth: true
                active: isAReply &&
                    root.messageDetails.contentType !== StatusMessage.ContentType.SystemMessagePinnedMessage &&
                    root.messageDetails.contentType !== StatusMessage.ContentType.SystemMessageMutualStateUpdate

                visible: active
                sourceComponent: StatusMessageReply {
                    objectName: "StatusMessage_replyDetails"
                    replyDetails: root.replyDetails
                    profileClickable: root.profileClickable
                    onReplyProfileClicked: root.replyProfileClicked(sender, mouse)
                    onMessageClicked: root.replyMessageClicked(mouse)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                StatusSmartIdenticon {
                    id: profileImage
                    Layout.alignment: Qt.AlignTop
                    active: root.showHeader
                    visible: active
                    name: root.messageDetails.sender.displayName
                    asset: root.messageDetails.sender.profileImage.assetSettings
                    ringSettings: root.messageDetails.sender.profileImage.ringSettings

                    MouseArea {
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        enabled: root.profileClickable
                        onClicked: root.profilePictureClicked(this, mouse)
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.leftMargin: profileImage.active ? 0 : root.messageDetails.sender.profileImage.assetSettings.width + parent.spacing

                    StatusPinMessageDetails {
                        active: root.isPinned && !editMode
                        visible: active
                        pinnedMsgInfoText: root.pinnedMsgInfoText
                        pinnedBy: root.pinnedBy
                    }
                    Loader {
                        Layout.fillWidth: true
                        active: root.showHeader && !editMode
                        visible: active
                        sourceComponent: StatusMessageHeader {
                            sender: root.messageDetails.sender
                            amISender: root.messageDetails.amISender
                            messageOriginInfo: root.messageDetails.messageOriginInfo
                            showResendButton: root.hasExpired && root.messageDetails.amISender && !editMode && !root.isInPinnedPopup
                            showSendingLoader: root.isSending && root.messageDetails.amISender && !editMode
                            resendError: root.messageDetails.amISender && !editMode ? root.resendError : ""
                            onClicked: root.senderNameClicked(sender, mouse)
                            onResendClicked: root.resendClicked()
                            timestamp: root.timestamp
                            showFullTimestamp: root.isInPinnedPopup
                            displayNameClickable: root.profileClickable
                        }
                    }
                    Loader {
                        Layout.fillWidth: true
                        active: (!root.editMode && !!root.messageDetails.messageText && !root.hideMessage
                                 && ((root.messageDetails.contentType === StatusMessage.ContentType.Text) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.Emoji) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.DiscordMessage) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.Invitation)))
                        visible: active
                        sourceComponent: StatusTextMessage {
                            objectName: "StatusMessage_textMessage"
                            messageDetails: root.messageDetails
                            isEdited: root.isEdited
                            allowShowMore: !root.isInPinnedPopup
                            textField.anchors.rightMargin: root.isInPinnedPopup ? /*Style.current.xlPadding*/ 32 : 0 // margin for the "Unpin" floating button
                            onLinkActivated: {
                                root.linkActivated(link);
                            }
                        }
                    }
                    Loader {
                        active: root.messageDetails.contentType === StatusMessage.ContentType.Image && !editMode
                        visible: active
                        Layout.fillWidth: true

                        sourceComponent: Column {
                            id: imagesColumn
                            spacing: 8
                            Loader {
                                active: root.messageDetails.messageText !== ""
                                anchors.left: parent.left
                                anchors.right: parent.right
                                visible: active
                                sourceComponent: StatusTextMessage {
                                    messageDetails: root.messageDetails
                                    allowShowMore: !root.isInPinnedPopup
                                    textField.anchors.rightMargin: root.isInPinnedPopup ? /*Style.current.xlPadding*/ 32 : 0 // margin for the "Unpin" floating button
                                    onLinkActivated: {
                                        root.linkActivated(link);
                                    }
                                }
                            }

                            Loader {
                                active: true
                                sourceComponent: StatusMessageImageAlbum {
                                    width: messageLayout.width
                                    album: root.messageDetails.albumCount > 0 ? root.messageDetails.album : [root.messageDetails.messageContent]
                                    albumCount: root.messageDetails.albumCount > 0 ? root.messageDetails.albumCount : 1
                                    imageWidth: Math.min(messageLayout.width / root.messageDetails.albumCount - 9 * (root.messageDetails.albumCount - 1), 144)
                                    shapeType: root.messageDetails.amISender ? StatusImageMessage.ShapeType.RIGHT_ROUNDED : StatusImageMessage.ShapeType.LEFT_ROUNDED
                                    onImageClicked: root.imageClicked(image, mouse, imageSource)
                                }
                            }
                        }
                    }

                    Loader {
                        active: root.messageAttachments && !editMode
                        visible: active
                        sourceComponent: Column {
                            spacing: 4
                            Layout.fillWidth: true
                            Repeater {
                                model: attachmentsModel
                                delegate: StatusImageMessage {
                                    source: model.source
                                    onClicked: root.imageClicked(image, mouse, imageSource)
                                    shapeType: root.messageDetails.amISender ? StatusImageMessage.ShapeType.RIGHT_ROUNDED : StatusImageMessage.ShapeType.LEFT_ROUNDED
                                }
                            }
                        }
                    }
                    StatusSticker {
                        active: root.messageDetails.contentType === StatusMessage.ContentType.Sticker && !editMode
                        visible: active
                        asset.isImage: true
                        asset.name: root.messageDetails.messageContent
                        onStickerLoaded: root.stickerLoaded()
                        onClicked: root.stickerClicked()
                    }
                    Loader {
                        active: root.messageDetails.contentType === StatusMessage.ContentType.Audio && !editMode
                        visible: active
                        sourceComponent: StatusAudioMessage {
                            audioSource: root.messageDetails.messageContent
                            hovered: root.hovered
                        }
                    }
                    Loader {
                        id: linksLoader
                        active: !root.editMode && root.hasLinks
                        visible: active
                    }
                    Loader {
                        id: transactionBubbleLoader
                        active: root.messageDetails.contentType === StatusMessage.ContentType.Transaction && !editMode
                        visible: active
                    }
                    Loader {
                        id: invitationBubbleLoader
                        active: root.messageDetails.contentType === StatusMessage.ContentType.Invitation && !editMode
                        visible: active
                    }

                    Loader {
                        Layout.fillWidth: true
                        Layout.rightMargin: 16
                        active: root.editMode
                        visible: active
                        sourceComponent: StatusEditMessage {
                            inputComponent: root.statusChatInput
                            messageText: root.messageDetails.messageText
                            onEditCancelled: root.editCancelled()
                            onEditCompleted: root.editCompleted(newMsgText)
                        }
                    }
                    Loader {
                        active: root.reactionsModel.count > 0
                        visible: active
                        sourceComponent: StatusMessageEmojiReactions {
                            id: emojiReactionsPanel
                            enabled: !root.disableEmojis
                            emojiReactionsModel: root.reactionsModel
                            icons: root.reactionIcons

                            onHoverChanged: {
                                root.hoverChanged(messageId, hovered)
                            }

                            isCurrentUser: root.messageDetails.amISender
                            onAddEmojiClicked: root.addReactionClicked(sender, mouse)
                            onToggleReaction: root.toggleReactionClicked(emojiID)
                        }
                    }
                }
            }
        }

        Loader {
            active: root.hovered && root.quickActions.length > 0
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: -8
            sourceComponent: StatusMessageQuickActions {
                items: root.quickActions
            }
        }
    }

    ListModel {
        id: attachmentsModel
        Component.onCompleted: {
            root.prepareAttachmentsModel()
        }
    }
}
