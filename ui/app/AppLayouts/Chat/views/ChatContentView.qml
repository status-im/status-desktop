import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"
import "../stores"

ColumnLayout {
    id: root

    // Important: each chat/channel has its own ChatContentModule
    property var chatContentModule
    property var chatSectionModule
    property var rootStore
    property var contactsStore
    property string chatId
    property int chatType: Constants.chatType.unknown

    readonly property alias chatMessagesLoader: chatMessagesLoader

    property var emojiPopup
    property var stickersPopup
    property UsersStore usersStore: UsersStore {}

    signal openStickerPackPopup(string stickerPackId)

    property bool isBlocked: false
    property bool isUserAllowedToSendMessage: root.rootStore.isUserAllowedToSendMessage
    property bool stickersLoaded: false

    readonly property var messageStore: MessageStore {
        messageModule: chatContentModule ? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    signal showReplyArea(messageId: string)
    signal forceInputFocus()

    objectName: "chatContentViewColumn"
    spacing: 0

    onChatContentModuleChanged: if (!!chatContentModule) {
        root.usersStore.usersModule = root.chatContentModule.usersModule
    }

    Loader {
        Layout.fillWidth: true
        active: root.isBlocked
        visible: active
        sourceComponent: StatusBanner {
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
        }
    }

    Loader {
        id: chatMessagesLoader
        Layout.fillWidth: true
        Layout.fillHeight: true

        sourceComponent: ChatMessagesView {
            chatContentModule: root.chatContentModule
            rootStore: root.rootStore
            contactsStore: root.contactsStore
            messageStore: root.messageStore
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            usersStore: root.usersStore
            stickersLoaded: root.stickersLoaded
            chatId: root.chatId
            isOneToOne: root.chatType === Constants.chatType.oneToOne
            isChatBlocked: root.isBlocked || !root.isUserAllowedToSendMessage
            channelEmoji: !chatContentModule ? "" : (chatContentModule.chatDetails.emoji || "")
            onShowReplyArea: (messageId, senderId) => {
                root.showReplyArea(messageId)
            }
            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }
            onEditModeChanged: {
                if (!editModeOn)
                    root.forceInputFocus()
            }
        }
    }
}
