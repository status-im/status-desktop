import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ 0.1
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
        Audio = 5, // Not used
        Transaction = 6,
        Invitation = 7,
        DiscordMessage = 8,
        SystemMessagePinnedMessage = 14,
        SystemMessageMutualEventSent = 15,
        SystemMessageMutualEventAccepted = 16,
        SystemMessageMutualEventRemoved = 17,
        BridgeMessage = 18
    }

    enum OutgoingStatus {
        Unknown = 0,
        Sending,
        Sent,
        Delivered,
        Expired,
        FailedResending
    }

    property list<Item> quickActions
    property var statusChatInput
    property alias linksComponent: linksLoader.sourceComponent
    property alias invitationComponent: invitationBubbleLoader.sourceComponent
    property alias mouseArea: mouseArea

    property string pinnedMsgInfoText: ""

    property string messageAttachments: ""
    property var reactionIcons: []
    property var linkPreviewModel
    property var paymentRequestModel
    property var gifLinks

    property string messageId: ""
    property bool editMode: false
    property bool isAReply: false
    property bool isEdited: false

    property bool hasMention: false
    property bool isPinned: false
    property string pinnedBy: ""
    property string resendError: ""
    property int outgoingStatus: StatusMessage.OutgoingStatus.Unknown
    property double timestamp: 0
    property var reactionsModel: []

    property bool showHeader: true
    property bool isActiveMessage: false
    property bool disableHover: false
    property bool disableEmojis: false
    property color overrideBackgroundColor: "transparent"
    property bool overrideBackground: false
    property bool profileClickable: true
    property bool hideMessage: false
    property bool isInPinnedPopup
    property string highlightedLink: ""
    property string hoveredLink: ""
    property bool linkAddressAndEnsName
    property string disabledTooltipText

    property StatusMessageDetails messageDetails: StatusMessageDetails {}
    property StatusMessageDetails replyDetails: StatusMessageDetails {}

    signal profilePictureClicked(var sender, var mouse)
    signal senderNameClicked(var sender)
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
        messageFoundAnimation.restart();
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
    opacity: outgoingStatus === StatusMessage.OutgoingStatus.Sending ? 0.5 : 1.0
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

            NumberAnimation {
                target: highlightRect
                property: "opacity"
                to: 1.0
                duration: 250
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

        StatusMouseArea {
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
                    root.messageDetails.contentType !== StatusMessage.ContentType.SystemMessageMutualEventSent &&
                    root.messageDetails.contentType !== StatusMessage.ContentType.SystemMessageMutualEventAccepted &&
                    root.messageDetails.contentType !== StatusMessage.ContentType.SystemMessageMutualEventRemoved

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
                    bridgeBadge.visible: root.messageDetails.contentType === StatusMessage.ContentType.BridgeMessage
                    bridgeBadge.image.source: root.messageDetails.sender.badgeImage

                    StatusMouseArea {
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
                            resendError: root.messageDetails.amISender ? root.resendError : ""
                            onClicked: (sender) => root.senderNameClicked(sender)
                            onResendClicked: root.resendClicked()
                            timestamp: root.timestamp
                            showFullTimestamp: root.isInPinnedPopup
                            displayNameClickable: root.profileClickable
                            outgoingStatus: root.outgoingStatus
                            showOutgointStatusLabel: root.hovered && !root.isInPinnedPopup
                        }
                    }
                    Loader {
                        Layout.fillWidth: true
                        active: (!root.editMode && !!root.messageDetails.messageText && !root.hideMessage
                                 && ((root.messageDetails.contentType === StatusMessage.ContentType.Text) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.Emoji) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.DiscordMessage) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.Invitation) ||
                                     (root.messageDetails.contentType === StatusMessage.ContentType.BridgeMessage)))
                        visible: active
                        sourceComponent: StatusTextMessage {
                            objectName: "StatusMessage_textMessage"
                            messageDetails: root.messageDetails
                            isEdited: root.isEdited
                            allowShowMore: !root.isInPinnedPopup
                            textField.anchors.rightMargin: root.isInPinnedPopup ? Theme.xlPadding : 0 // margin for the "Unpin" floating button
                            highlightedLink: root.highlightedLink
                            linkAddressAndEnsName: root.linkAddressAndEnsName
                            disabledTooltipText: root.disabledTooltipText
                            onLinkActivated: {
                                root.linkActivated(link);
                            }
                            textField.onHoveredLinkChanged: {
                                root.hoveredLink = hoveredLink;
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
                                    objectName: "StatusMessage_textMessage"
                                    messageDetails: root.messageDetails
                                    isEdited: root.isEdited
                                    allowShowMore: !root.isInPinnedPopup
                                    textField.anchors.rightMargin: root.isInPinnedPopup ? Theme.xlPadding : 0 // margin for the "Unpin" floating button
                                    highlightedLink: root.highlightedLink
                                    onLinkActivated: {
                                        root.linkActivated(link);
                                    }
                                }
                            }

                            Loader {
                                active: true
                                sourceComponent: StatusMessageImageAlbum {
                                    objectName: "StatusMessage_imageAlbum"
                                    width: messageLayout.width
                                    album: root.messageDetails.albumCount > 0 ? root.messageDetails.album : [root.messageDetails.messageContent]
                                    albumCount: root.messageDetails.albumCount > 0 ? root.messageDetails.albumCount : 1
                                    imageWidth: Math.min(messageLayout.width / root.messageDetails.albumCount - 9 * (root.messageDetails.albumCount - 1), 144)
                                    shapeType: StatusImageMessage.ShapeType.LEFT_ROUNDED
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
                                    shapeType: StatusImageMessage.ShapeType.LEFT_ROUNDED
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
                        id: linksLoader
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        active: !root.editMode &&
                                ((!!root.linkPreviewModel && root.linkPreviewModel.count > 0)
                                || (!!root.gifLinks && root.gifLinks.length > 0)
                                || (!!root.paymentRequestModel && root.paymentRequestModel.ModelCount.count > 0))
                        visible: active 
                    }
                    Loader {
                        id: invitationBubbleLoader
                        // TODO remove this component in #12570
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
