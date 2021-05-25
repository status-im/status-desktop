import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ChatColumn"

ModalPopup {
    id: popup

    header: Item {
        height: childrenRect.height
        width: parent.width

        StyledText {
            id: title
            text: qsTr("Pinned messages")
            anchors.top: parent.top
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: 17
        }

        StyledText {
            id: nbPinnedMessages
            text: qsTr("%1 message").arg(pinnedMessageListView.count)
            anchors.left: parent.left
            anchors.top: title.bottom
            anchors.topMargin: 2
            font.pixelSize: 15
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

    ListView {
        id: pinnedMessageListView
        model: chatsModel.pinnedMessagesList
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: -Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
        clip: true

        delegate: Message {
            fromAuthor: model.fromAuthor
            chatId: model.chatId
            userName: model.userName
            alias: model.alias
            localName: model.localName
            message: model.message
            plainText: model.plainText
            identicon: model.identicon
            isCurrentUser: model.isCurrentUser
            timestamp: model.timestamp
            sticker: model.sticker
            contentType: model.contentType
            outgoingStatus: model.outgoingStatus
            responseTo: model.responseTo
            imageClick: imagePopup.openPopup.bind(imagePopup)
            messageId: model.messageId
            emojiReactions: model.emojiReactions
            linkUrls: model.linkUrls
            communityId: model.communityId
            hasMention: model.hasMention
            stickerPackId: model.stickerPackId
            timeout: model.timeout
            pinnedMessage: true
            forceHoverHandler: true
        }
    }

    footer: StatusRoundButton {
        id: btnBack
        anchors.left: parent.left
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        rotation: 180
        onClicked: popup.close()
    }
}
