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
import shared.stores 1.0 as SharedStores
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import AppLayouts.Profile.stores 1.0

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

    property RootStore rootStore
    property ContactsStore contactsStore
    property string chatId
    property int chatType: Constants.chatType.unknown
    property var formatBalance

    readonly property alias chatMessagesLoader: chatMessagesLoader
    property bool areTestNetworksEnabled

    property var emojiPopup
    property var stickersPopup

    // Users related data:
    property var usersModel

    signal openStickerPackPopup(string stickerPackId)
    signal tokenPaymentRequested(string recipientAddress, string symbol, string rawAmount, int chainId)

    property bool isBlocked: false
    property bool isUserAllowedToSendMessage: root.rootStore.isUserAllowedToSendMessage
    property bool stickersLoaded: false

    readonly property MessageStore messageStore: MessageStore {
        messageModule: chatContentModule ? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    property bool sendViaPersonalChatEnabled
    property string disabledTooltipText

    signal showReplyArea(messageId: string)
    signal forceInputFocus()

    // Unfurling related data:
    property bool gifUnfurlingEnabled
    property bool neverAskAboutUnfurlingAgain

    signal setNeverAskAboutUnfurlingAgain(bool neverAskAgain)

    signal openGifPopupRequest(var params, var cbOnGifSelected, var cbOnClose)

    objectName: "chatContentViewColumn"
    spacing: 0

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
            formatBalance: root.formatBalance
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            stickersLoaded: root.stickersLoaded
            chatId: root.chatId
            isOneToOne: root.chatType === Constants.chatType.oneToOne
            isChatBlocked: root.isBlocked || !root.isUserAllowedToSendMessage
            isContactBlocked: root.isBlocked
            channelEmoji: !chatContentModule ? "" : (chatContentModule.chatDetails.emoji || "")
            sendViaPersonalChatEnabled: root.sendViaPersonalChatEnabled
            disabledTooltipText: root.disabledTooltipText
            areTestNetworksEnabled: root.areTestNetworksEnabled
            usersModel: root.usersModel

            // Unfurling related data:
            gifUnfurlingEnabled: root.gifUnfurlingEnabled
            neverAskAboutUnfurlingAgain: root.neverAskAboutUnfurlingAgain

            onShowReplyArea: (messageId, senderId) => {
                root.showReplyArea(messageId)
            }
            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }
            onTokenPaymentRequested: root.tokenPaymentRequested(recipientAddress, symbol, rawAmount, chainId)
            onEditModeChanged: {
                if (!editModeOn)
                    root.forceInputFocus()
            }

            // Unfurling related requests:
            onSetNeverAskAboutUnfurlingAgain: root.setNeverAskAboutUnfurlingAgain(neverAskAgain)

            onOpenGifPopupRequest: root.openGifPopupRequest(params, cbOnGifSelected, cbOnClose)
        }
    }
}
