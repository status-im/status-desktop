import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "./private/statusMessage"

Rectangle {
    id: statusMessage

    enum ContentType {
        Unknown = 0,
        Text = 1,
        Emoji = 2,
        Image = 3,
        Sticker = 4,
        Audio = 5,
        Transaction = 6,
        Invitation = 7
    }

    enum ContactType {
        STANDARD = 0,
        RENAME = 1,
        CONTACT = 2,
        VERIFIED = 3,
        UNTRUSTWORTHY = 4
    }

    property alias messageHeader: messageHeader
    property alias quickActions:quickActionsPanel.quickActions
    property alias statusChatInput: editComponent.inputComponent
    property alias linksComponent: linksLoader.sourceComponent
    property alias footerComponent: footer.sourceComponent
    property alias timestamp: messageHeader.timestamp

    property string resendText: ""
    property string cancelButtonText: ""
    property string saveButtonText: ""
    property string loadingImageText: ""
    property string errorLoadingImageText: ""
    property string audioMessageInfoText: ""
    property string pinnedMsgInfoText: ""

    property bool isAppWindowActive: false
    property bool editMode: false
    property bool isAReply: false
    property StatusMessageDetails messageDetails: StatusMessageDetails {}
    property StatusMessageDetails replyDetails: StatusMessageDetails {}

    signal profilePictureClicked()
    signal senderNameClicked()
    signal editCompleted(var newMsgText)
    signal replyProfileClicked()
    signal stickerLoaded()
    signal imageClicked(var imageSource)
    signal resendClicked()

    height: childrenRect.height
    color: hoverHandler.hovered ? (messageDetails.hasMention ? Theme.palette.mentionColor3 : messageDetails.isPinned ? Theme.palette.pinColor2 :  Theme.palette.baseColor2) : messageDetails.hasMention  ? Theme.palette.mentionColor4 : messageDetails.isPinned ? Theme.palette.pinColor3 : "transparent"

    HoverHandler {
        id: hoverHandler
    }

    ColumnLayout {
        id: messageLayout
        width: parent.width
        StatusMessageReply {
            Layout.fillWidth: true
            visible: isAReply
            replyDetails: statusMessage.replyDetails
            onReplyProfileClicked: statusMessage.replyProfileClicked()
            audioMessageInfoText: statusMessage.audioMessageInfoText
        }
        RowLayout {
            spacing: 8
            Layout.fillWidth: true
            StatusSmartIdenticon {
                id: profileImage
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 10
                Layout.leftMargin: 16
                image: messageDetails.profileImage
                name: messageHeader.displayName
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    onClicked: statusMessage.profilePictureClicked()
                }
            }
            Column {
                spacing: 4
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 10
                Layout.fillWidth: true
                StatusPinMessageDetails {
                    visible: messageDetails.isPinned && !editMode
                    pinnedMsgInfoText: statusMessage.pinnedMsgInfoText
                    pinnedBy: messageDetails.pinnedBy
                }
                StatusMessageHeader {
                    id: messageHeader
                    width: parent.width
                    displayName: messageDetails.displayName
                    secondaryName: messageDetails.secondaryName
                    tertiaryDetail: messageDetails.chatID
                    icon1.name: messageDetails.contactType === StatusMessage.ContactType.CONTACT ? "tiny/tiny-contact" : ""
                    icon2.name: messageDetails.contactType === StatusMessage.ContactType.VERIFIED ? "tiny/tiny-checkmark" :
                                messageDetails.contactType === StatusMessage.ContactType.UNTRUSTWORTHY ? "tiny/subtract": ""
                    icon2.background.color:  messageDetails.contactType === StatusMessage.ContactType.UNTRUSTWORTHY ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
                    icon2.color: Theme.palette.indirectColor1
                    resendText: statusMessage.resendText
                    showResendButton: messageDetails.hasExpired && messageDetails.amISender
                    onClicked: statusMessage.senderNameClicked()
                    onResendClicked: statusMessage.resendClicked()
                    visible: !editMode
                }
                Loader {
                    active: !editMode && !!messageDetails.messageText
                    width: parent.width
                    visible: active
                    sourceComponent: StatusTextMessage {
                        width: parent.width
                        textField.text: messageDetails.messageText
                    }
                }
                Loader {
                    active: messageDetails.contentType === StatusMessage.ContentType.Image && !editMode
                    visible: active
                    sourceComponent: StatusImageMessage {
                        source: messageDetails.contentType === StatusMessage.ContentType.Image ? messageDetails.messageContent : ""
                        onClicked: statusMessage.imageClicked()
                        shapeType: messageDetails.amISender ? StatusImageMessage.ShapeType.RIGHT_ROUNDED : StatusImageMessage.ShapeType.LEFT_ROUNDED
                    }
                }
                StatusSticker {
                    visible: messageDetails.contentType === StatusMessage.ContentType.Sticker && !editMode
                    image.source: messageDetails.messageContent
                    onLoaded: statusMessage.stickerLoaded()
                }
                Loader {
                    active: messageDetails.contentType === StatusMessage.ContentType.Audio && !editMode
                    visible: active
                    sourceComponent: StatusAudioMessage {
                        audioSource: messageDetails.messageContent
                        hovered: hoverHandler.hovered
                        audioMessageInfoText: statusMessage.audioMessageInfoText
                    }
                }
                Loader {
                    id: linksLoader
                    active: !!linksLoader.sourceComponent
                    visible: active
                }
                Loader {
                    id: transactionBubbleLoader
                    active: messageDetails.contentType === StatusMessage.ContentType.Transaction && !editMode
                    visible: active
                }
                Loader {
                    id: invitationBubbleLoader
                    active: messageDetails.contentType === StatusMessage.ContentType.Invitation && !editMode
                    visible: active
                }
                StatusEditMessage {
                    id: editComponent
                    width: parent.width
                    msgText: messageDetails.messageText
                    visible: editMode
                    saveButtonText: statusMessage.saveButtonText
                    cancelButtonText: statusMessage.cancelButtonText
                    onCancelEditClicked: editMode = false
                    onEditCompleted: {
                        editMode = false
                        statusMessage.editCompleted(newMsgText)
                    }
                }
                StatusBaseText {
                    id: retryLbl
                    color: Theme.palette.dangerColor1
                    text: statusMessage.resendText
                    font.pixelSize: 12
                    visible: messageDetails.hasExpired && messageDetails.amISender && !messageDetails.timestamp && !editMode
                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: statusMessage.resendClicked()
                    }
                }
                Loader {
                    id: footer
                    active: sourceComponent && !editMode
                    visible: active
                }
            }
        }
    }

    StatusMessageQuickActions {
        id: quickActionsPanel
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: -8
        visible: hoverHandler.hovered && !editMode
    }
}
