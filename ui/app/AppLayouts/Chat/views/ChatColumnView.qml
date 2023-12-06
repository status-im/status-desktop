import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0
import shared.popups.send 1.0
import SortFilterProxyModel 0.2

import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.panels 1.0

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"
import "../stores"

Item {
    id: root

    // Important: we have parent module in this context only cause qml components
    // don't follow struct we have on the backend.
    property var parentModule

    property var rootStore
    property var createChatPropertiesStore
    property var contactsStore
    property var emojiPopup
    property var stickersPopup

    property string activeChatId: parentModule && parentModule.activeItem.id
    property int chatsCount: parentModule && parentModule.model ? parentModule.model.count : 0
    property int activeChatType: parentModule && parentModule.activeItem.type
    property bool stickersLoaded: false
    property bool viewAndPostPermissionsSatisfied: true
    property var viewAndPostHoldingsModel

    readonly property var contactDetails: rootStore ? rootStore.oneToOneChatContact : null
    readonly property bool isUserAdded: !!root.contactDetails && root.contactDetails.isAdded
    property bool amISectionAdmin: false

    signal openStickerPackPopup(string stickerPackId)

    // This function is called once `1:1` or `group` chat is created.
    function checkForCreateChatOptions(chatId) {
        if (root.createChatPropertiesStore.createChatStickerHashId !== ""
                && root.createChatPropertiesStore.createChatStickerPackId !== ""
                && root.createChatPropertiesStore.createChatStickerUrl !== "") {
            root.rootStore.sendSticker(
                        chatId,
                        root.createChatPropertiesStore.createChatStickerHashId,
                        "",
                        root.createChatPropertiesStore.createChatStickerPackId,
                        root.createChatPropertiesStore.createChatStickerUrl)
        } else if (root.createChatPropertiesStore.createChatInitMessage !== ""
                 || root.createChatPropertiesStore.createChatFileUrls.length > 0) {
            root.rootStore.sendMessage(
                        chatId, Qt.Key_Enter,
                        root.createChatPropertiesStore.createChatInitMessage,
                        "", root.createChatPropertiesStore.createChatFileUrls)
        }

        root.createChatPropertiesStore.resetProperties()
    }

    QtObject {
        id: d
        readonly property var activeChatContentModule: d.getChatContentModule(root.activeChatId)

        readonly property var urlsList: {
            urlsModelChangeTracker.revision
            ModelUtils.modelToFlatArray(d.activeChatContentModule.inputAreaModule.urlsModel, "url")
        }

        readonly property ModelChangeTracker urlsModelChangeTracker: ModelChangeTracker {
            model: d.activeChatContentModule.inputAreaModule.urlsModel
        }

        readonly property UsersStore activeUsersStore: UsersStore {
            usersModule: !!d.activeChatContentModule ? d.activeChatContentModule.usersModule : null
        }

        readonly property MessageStore activeMessagesStore: MessageStore {
            messageModule: d.activeChatContentModule ? d.activeChatContentModule.messagesModule : null
            chatSectionModule: root.rootStore.chatCommunitySectionModule
        }

        readonly property string linkPreviewBeginAnchor: `<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.messaging}">`
        readonly property string linkPreviewEndAnchor: `</a>`

        readonly property string linkPreviewEnabledNotification: qsTr("Link previews will be shown for all sites. You can manage link previews in %1.", "Go to settings").arg(linkPreviewBeginAnchor + qsTr("Settings", "Go to settings page") + linkPreviewEndAnchor)
        readonly property string linkPreviewDisabledNotification: qsTr("Link previews will never be shown. You can manage link previews in %1.").arg(linkPreviewBeginAnchor + qsTr("Settings", "Go to settings page") + linkPreviewEndAnchor)
        readonly property string linkPreviewEnabledForMessageNotification: qsTr("Link previews will be shown for this message. You can manage link previews in %1.").arg(linkPreviewBeginAnchor + qsTr("Settings", "Go to settings page") + linkPreviewEndAnchor)

        function getChatContentModule(chatId) {
            root.parentModule.prepareChatContentModuleForChatId(chatId)
            return root.parentModule.getChatContentModule()
        }

        function showReplyArea(messageId) {
            const obj = d.activeMessagesStore.getMessageByIdAsJson(messageId)
            if (!obj)
                return
            chatInput.showReplyArea(messageId,
                                    obj.senderDisplayName,
                                    obj.messageText,
                                    obj.contentType,
                                    obj.messageImage,
                                    obj.albumMessageImages,
                                    obj.albumImagesCount,
                                    obj.sticker)
        }

        function restoreInputReply() {
            const replyMessageId = d.activeChatContentModule.inputAreaModule.preservedProperties.replyMessageId
            if (replyMessageId)
                d.showReplyArea(replyMessageId)
            else
                chatInput.resetReplyArea()
        }

        function restoreInputAttachments() {
            const filesJson = d.activeChatContentModule.inputAreaModule.preservedProperties.fileUrlsAndSourcesJson
            let filesList = []
            if (filesJson) {
                try {
                    filesList = JSON.parse(filesJson)
                } catch(e) {
                    console.error("failed to parse preserved fileUrlsAndSources")
                }
            }
            chatInput.resetImageArea()
            chatInput.validateImagesAndShowImageArea(filesList)
        }

        function restoreInputState(textInput) {

            if (!d.activeChatContentModule) {
                chatInput.clear()
                chatInput.resetReplyArea()
                chatInput.resetImageArea()
                return
            }

            // Restore message text
            chatInput.setText(textInput)

            d.restoreInputReply()
            d.restoreInputAttachments()
        }

        readonly property var updateLinkPreviews: {
            return Backpressure.debounce(this, 250, () => {
                                             const messageText = root.rootStore.cleanMessageText(chatInput.textInput.text)
                                             d.activeChatContentModule.inputAreaModule.setText(messageText)
                                         })
        }

        onActiveChatContentModuleChanged: {
            let preservedText = ""
            if (d.activeChatContentModule) {
                preservedText = d.activeChatContentModule.inputAreaModule.preservedProperties.text
            }

            d.activeChatContentModule.inputAreaModule.clearLinkPreviewCache()
            // Call later to make sure activeUsersStore and activeMessagesStore bindings are updated
            Qt.callLater(d.restoreInputState, preservedText)
        }
    }

    EmptyChatPanel {
        anchors.fill: parent
        visible: root.activeChatId === "" || root.chatsCount == 0
        rootStore: root.rootStore
        onShareChatKeyClicked: Global.openProfilePopup(userProfile.pubKey);
    }

    // This is kind of a solution for applying backend refactored changes with the minimal qml changes.
    // The best would be if we made qml to follow the struct we have on the backend side.

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                id: chatRepeater
                model: parentModule && parentModule.model

                ChatContentView {
                    width: parent.width
                    height: parent.height
                    visible: !root.rootStore.openCreateChat && model.active
                    chatId: model.itemId
                    chatType: model.type
                    chatMessagesLoader.active: model.loaderActive
                    rootStore: root.rootStore
                    contactsStore: root.contactsStore
                    emojiPopup: root.emojiPopup
                    stickersPopup: root.stickersPopup
                    stickersLoaded: root.stickersLoaded
                    isBlocked: model.blocked
                    onOpenStickerPackPopup: {
                        root.openStickerPackPopup(stickerPackId)
                    }
                    onShowReplyArea: (messageId) => {
                                         d.showReplyArea(messageId)
                                     }
                    onForceInputFocus: {
                        chatInput.forceInputActiveFocus()
                    }

                    Component.onCompleted: {
                        chatContentModule = d.getChatContentModule(model.itemId)
                        chatSectionModule = root.parentModule
                        root.checkForCreateChatOptions(model.itemId)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Style.current.smallPadding
            Layout.preferredHeight: chatInputItem.height

            Item {
                id: chatInputItem
                Layout.fillWidth: true
                Layout.preferredHeight: chatInput.height

                StatusChatInput {
                    id: chatInput
                    width: parent.width
                    visible: !!d.activeChatContentModule
                    
                    // When `enabled` is switched true->false, `textInput.text` is cleared before d.activeChatContentModule updates.
                    // We delay the binding so that the `inputAreaModule.preservedProperties.text` doesn't get overriden with empty value.
                    Binding on enabled {
                        delayed: true
                        value: !!d.activeChatContentModule
                                 && !d.activeChatContentModule.chatDetails.blocked
                                 && root.rootStore.sectionDetails.joined
                                 && !root.rootStore.sectionDetails.amIBanned
                                 && root.rootStore.isUserAllowedToSendMessage
                    }

                    store: root.rootStore
                    usersStore: d.activeUsersStore
                    linkPreviewModel: d.activeChatContentModule.inputAreaModule.linkPreviewModel
                    urlsList: d.urlsList
                    askToEnableLinkPreview: {
                        if(!d.activeChatContentModule || !d.activeChatContentModule.inputAreaModule || !d.activeChatContentModule.inputAreaModule.preservedProperties)
                            return false

                        return d.activeChatContentModule.inputAreaModule.askToEnableLinkPreview
                    }
                    textInput.placeholderText: {
                        if (!channelPostRestrictions.visible) {
                            if (d.activeChatContentModule.chatDetails.blocked)
                                return qsTr("This user has been blocked.")
                            if (!root.rootStore.sectionDetails.joined || root.rootStore.sectionDetails.amIBanned) {
                                return qsTr("You need to join this community to send messages")
                            }
                            if (!root.viewAndPostPermissionsSatisfied) {
                                return qsTr("Sorry, you don't have the tokens needed to post in this channel.")
                            }
                            return root.rootStore.chatInputPlaceHolderText
                        } else {
                            return "";
                        }
                    }

                    emojiPopup: root.emojiPopup
                    stickersPopup: root.stickersPopup
                    chatType: root.activeChatType

                    textInput.onTextChanged: {
                        if (!!d.activeChatContentModule && textInput.text !== d.activeChatContentModule.inputAreaModule.preservedProperties.text) {
                            d.activeChatContentModule.inputAreaModule.preservedProperties.text = textInput.text
                            d.updateLinkPreviews()
                        }
                    }

                    onReplyMessageIdChanged: {
                        if (!!d.activeChatContentModule)
                            d.activeChatContentModule.inputAreaModule.preservedProperties.replyMessageId = replyMessageId
                    }

                    onFileUrlsAndSourcesChanged: {
                        if (!!d.activeChatContentModule)
                            d.activeChatContentModule.inputAreaModule.preservedProperties.fileUrlsAndSourcesJson = JSON.stringify(chatInput.fileUrlsAndSources)
                    }

                    onStickerSelected: {
                        root.rootStore.sendSticker(d.activeChatContentModule.getMyChatId(),
                                                   hashId,
                                                   chatInput.isReply ? chatInput.replyMessageId : "",
                                                   packId,
                                                   url)
                    }

                    onSendMessage: {
                        if (!d.activeChatContentModule) {
                            console.debug("error on sending message - chat content module is not set")
                            return
                        }

                         if (root.rootStore.sendMessage(d.activeChatContentModule.getMyChatId(),
                                                        event,
                                                        chatInput.getTextWithPublicKeys(),
                                                        chatInput.isReply? chatInput.replyMessageId : "",
                                                        chatInput.fileUrlsAndSources
                                                        ))
                         {
                             Global.playSendMessageSound()

                             chatInput.setText("")
                             chatInput.textInput.textFormat = TextEdit.PlainText;
                             chatInput.textInput.textFormat = TextEdit.RichText;
                         }
                    }

                    onKeyUpPress: {
                        d.activeMessagesStore.setEditModeOnLastMessage(root.rootStore.userProfileInst.pubKey)
                    }
                    
                    onLinkPreviewReloaded: (link) => d.activeChatContentModule.inputAreaModule.reloadLinkPreview(link)
                    onEnableLinkPreview: () => {
                        d.activeChatContentModule.inputAreaModule.enableLinkPreview()
                        Global.displayToastMessage(d.linkPreviewEnabledNotification, "", "show", false, Constants.ephemeralNotificationType.success, "")
                    }
                    onDisableLinkPreview: () => {
                        d.activeChatContentModule.inputAreaModule.disableLinkPreview()
                        Global.displayToastMessage(d.linkPreviewDisabledNotification, "", "hide", false, Constants.ephemeralNotificationType.danger, "")
                    }
                    onEnableLinkPreviewForThisMessage: () => {
                        d.activeChatContentModule.inputAreaModule.setLinkPreviewEnabledForCurrentMessage(true)
                        Global.displayToastMessage(d.linkPreviewEnabledForMessageNotification, "", "show", false, Constants.ephemeralNotificationType.success, "")
                    }
                    onDismissLinkPreviewSettings: () => {
                        d.activeChatContentModule.inputAreaModule.setLinkPreviewEnabledForCurrentMessage(false)
                    }
                    onDismissLinkPreview: (index) => d.activeChatContentModule.inputAreaModule.removeLinkPreviewData(index)
                }

                ChatPermissionQualificationPanel {
                    id: channelPostRestrictions
                    width: chatInput.textInput.width
                    height: chatInput.textInput.height
                    anchors.left: parent.left
                    anchors.leftMargin: (2*Style.current.bigPadding)
                    visible: (!!root.viewAndPostHoldingsModel && (root.viewAndPostHoldingsModel.count > 0)
                              && !root.amISectionAdmin && !root.viewAndPostPermissionsSatisfied)
                    assetsModel: root.rootStore.assetsModel
                    collectiblesModel: root.rootStore.collectiblesModel
                    holdingsModel: root.viewAndPostHoldingsModel
                }
            }

            StatusButton {
                Layout.fillHeight: true
                Layout.maximumHeight: chatInput.implicitHeight
                verticalPadding: 0
                visible: !!d.activeChatContentModule && d.activeChatContentModule.chatDetails.blocked
                text: qsTr("Unblock")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    if (!!d.activeChatContentModule)
                        d.activeChatContentModule.unblockChat()
                }
            }
        }
    }
}
