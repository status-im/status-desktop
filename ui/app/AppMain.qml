import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13

import utils 1.0
import "../shared"
import "../shared/status"
import "../shared/popups"
import "./AppLayouts"
import "./AppLayouts/Timeline"
import "./AppLayouts/Wallet"
import "./AppLayouts/WalletV2"
import "./AppLayouts/Chat/components"
import "./AppLayouts/Chat/CommunityComponents"
import "./AppLayouts/Profile/Sections"

import Qt.labs.platform 1.1
import Qt.labs.settings 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1


Item {
    id: appMain
    anchors.fill: parent

    property alias appLayout: appLayout
    property var newVersionJSON: JSON.parse(utilsModel.newVersion)
    property bool profilePopupOpened: false
    property bool networkGuarded: profileModel.network.current === Constants.networkMainnet || (profileModel.network.current === Constants.networkRopsten && appSettings.stickersEnsRopsten)

    signal settingsLoaded()
    signal openContactsPopup()

    function changeAppSection(section) {
        appSettings.lastModeActiveCommunity = ""
        chatsModel.communities.activeCommunity.active = false
        appView.currentIndex = Utils.getAppSectionIndex(section)
    }

    function getProfileImage(pubkey, isCurrentUser, useLargeImage) {
        if (isCurrentUser || (isCurrentUser === undefined && pubkey === profileModel.profile.pubKey)) {
            return profileModel.profile.thumbnailImage
        }

        const index = profileModel.contacts.list.getContactIndexByPubkey(pubkey)
        if (index === -1) {
            return
        }

        if (appSettings.onlyShowContactsProfilePics) {
            const isContact = profileModel.contacts.list.rowData(index, "isContact")
            if (isContact === "false") {
                return
            }
        }

        return profileModel.contacts.list.rowData(index, useLargeImage ? "largeImage" : "thumbnailImage")
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(appMain, params);
        popup.open()
        return popup
    }

    function getContactListObject(dataModel) {
        const nbContacts = profileModel.contacts.list.rowCount()
        const contacts = []
        let contact
        for (let i = 0; i < nbContacts; i++) {
            if (profileModel.contacts.list.rowData(i, "isBlocked") === "true") {
                continue
            }

            contact = {
                name: profileModel.contacts.list.rowData(i, "name"),
                localNickname: profileModel.contacts.list.rowData(i, "localNickname"),
                pubKey: profileModel.contacts.list.rowData(i, "pubKey"),
                address: profileModel.contacts.list.rowData(i, "address"),
                identicon: profileModel.contacts.list.rowData(i, "identicon"),
                thumbnailImage: profileModel.contacts.list.rowData(i, "thumbnailImage"),
                isUser: false,
                isContact: profileModel.contacts.list.rowData(i, "isContact") !== "false"
            }

            contacts.push(contact)
            if (dataModel) {
                dataModel.append(contact);
            }
        }
        return contacts
    }

    function getUserNickname(pubKey) {
        // Get contact nickname
        const contactList = profileModel.contacts.list
        const contactCount = contactList.rowCount()
        for (let i = 0; i < contactCount; i++) {
            if (contactList.rowData(i, 'pubKey') === pubKey) {
                return contactList.rowData(i, 'localNickname')
            }
        }
        return ""
    }

    function openLink(link) {
        if (appSettings.showBrowserSelector) {
            appMain.openPopup(chooseBrowserPopupComponent, {link: link})
        } else {
            if (appSettings.openLinksInStatus) {
                appMain.changeAppSection(Constants.browser)
                browserLayoutContainer.item.openUrlInNewTab(link)
            } else {
                Qt.openUrlExternally(link)
            }
        }
    }

    function openProfilePopup(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, parentPopup){
        var popup = profilePopupComponent.createObject(appMain);
        if(parentPopup){
            popup.parentPopup = parentPopup;
        }
        popup.openPopup(profileModel.profile.pubKey !== fromAuthorParam, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam);
        profilePopupOpened = true
    }

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        onClosed: {
            if(profilePopup.parentPopup){
                profilePopup.parentPopup.close();
            }
            profilePopupOpened = false
            destroy()
        }
    }

    Component {
        id: downloadModalComponent
        DownloadModal {
            onClosed: {
                destroy();
            }
        }
    }

    Audio {
        id: errorSound
        track: "error.mp3"
    }

    Audio {
        id: sendMessageSound
        track: "send_message.wav"
    }

    Audio {
        id: notificationSound
        track: "notification.wav"
    }

    ModuleWarning {
        id: versionWarning
        width: parent.width
        visible: newVersionJSON.available
        color: Style.current.green
        btnWidth: 100
        text: qsTr("A new  version of Status (%1) is available").arg(newVersionJSON.version)
        btnText: qsTr("Download") 
        onClick: function(){
            openPopup(downloadModalComponent, {newVersionAvailable: newVersionJSON.available, downloadURL: newVersionJSON.url})
        }
    }

    StatusAppLayout {
        id: appLayout

        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: versionWarning.visible ? 32 : 0
        anchors.bottom: parent.bottom

        appNavBar: StatusAppNavBar {
            height: appMain.height

            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                checked: !chatsModel.communities.activeCommunity.active  && appView.currentIndex === Utils.getAppSectionIndex(Constants.chat)
                //% "Chat"
                tooltip.text: qsTrId("chat")
                badge.value: chatsModel.messageView.unreadDirectMessagesAndMentionsCount + profileModel.contacts.contactRequests.count
                badge.visible: badge.value > 0 || (chatsModel.messageView.unreadMessagesCount > 0 && !checked)
                badge.anchors.rightMargin: badge.value > 0 ? 0 : 4
                badge.anchors.topMargin: badge.value > 0 ? 4 : 5
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                badge.border.width: 2
                onClicked: {
                    if (chatsModel.communities.activeCommunity.active) {
                        chatLayoutContainer.chatColumn.hideChatInputExtendedArea();
                        chatsModel.communities.activeCommunity.active = false
                    }
                    appMain.changeAppSection(Constants.chat)
                }
            }

            navBarCommunityTabButtons.model: appSettings.communitiesEnabled && chatsModel.communities.joinedCommunities
            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                onClicked: {
                    appMain.changeAppSection(Constants.chat)
                    chatsModel.communities.setActiveCommunity(model.id)
                    appSettings.lastModeActiveCommunity = model.id
                }

                anchors.horizontalCenter: parent.horizontalCenter

                checked: chatsModel.communities.activeCommunity.active && chatsModel.communities.activeCommunity.id === model.id
                name: model.name
                tooltip.text: model.name
                icon.color: model.communityColor
                icon.source: model.thumbnailImage

                badge.value: model.unviewedMentionsCount + model.requestsCount
                badge.visible: badge.value > 0 || (!checked && model.unviewedMessagesCount > 0)
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                badge.anchors.rightMargin: 4
                badge.anchors.topMargin: 5

                popupMenu: StatusPopupMenu {
                    id: communityContextMenu

                    openHandler: function () {
                        chatsModel.communities.setObservedCommunity(model.id)
                    }

                    StatusMenuItem {
                        //% "Invite People"
                        text: qsTrId("invite-people")
                        icon.name: "share-ios"
                        enabled: chatsModel.communities.observedCommunity.canManageUsers
                        onTriggered: openPopup(inviteFriendsToCommunityPopup, {
                            community: chatsModel.communities.observedCommunity
                        })
                    }

                    StatusMenuItem {
                        //% "View Community"
                        text: qsTrId("view-community")
                        icon.name: "group-chat"
                        onTriggered: openPopup(communityProfilePopup, {
                            community: chatsModel.communities.observedCommunity
                        })
                    }

                    StatusMenuItem {
                        enabled: chatsModel.communities.observedCommunity.admin
                        //% "Edit Community"
                        text: qsTrId("edit-community")
                        icon.name: "edit"
                        onTriggered: openPopup(editCommunityPopup, {community: chatsModel.communities.observedCommunity})
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        //% "Leave Community"
                        text: qsTrId("leave-community")
                        icon.name: "arrow-right"
                        icon.width: 14
                        iconRotation: 180
                        type: StatusMenuItem.Type.Danger
                        onTriggered: chatsModel.communities.leaveCommunity(model.id)
                    }
                }
            }

            navBarTabButtons: [
                StatusNavBarTabButton {
                    icon.name: "wallet"
                    //% "Wallet"
                    tooltip.text: qsTrId("wallet")
                    visible: enabled
                    enabled: isExperimental === "1" || appSettings.isWalletEnabled
                    checked: appView.currentIndex == Utils.getAppSectionIndex(Constants.wallet)
                    onClicked: appMain.changeAppSection(Constants.wallet)
                },

                StatusNavBarTabButton {
                    //TODO temporary icon name, switch back to wallet
                    icon.name: "cancel"
                    tooltip.text: qsTr("Wallet v2 - do not use, under active development")
                    visible: enabled
                    enabled: isExperimental === "1" || appSettings.isWalletV2Enabled
                    checked: appView.currentIndex == Utils.getAppSectionIndex(Constants.walletv2)
                    onClicked: appMain.changeAppSection(Constants.walletv2)
                },

                StatusNavBarTabButton {
                    enabled: isExperimental === "1" || appSettings.isBrowserEnabled
                    visible: enabled
                    //% "Browser"
                    tooltip.text: qsTrId("browser")
                    icon.name: "browser"
                    checked: appView.currentIndex == Utils.getAppSectionIndex(Constants.browser)
                    onClicked: appMain.changeAppSection(Constants.browser)
                },

                StatusNavBarTabButton {
                    enabled: isExperimental === "1" || appSettings.timelineEnabled
                    visible: enabled
                    //% "Timeline"
                    tooltip.text: qsTrId("timeline")
                    icon.name: "status-update"
                    checked: appView.currentIndex == Utils.getAppSectionIndex(Constants.timeline)
                    onClicked: appMain.changeAppSection(Constants.timeline)
                },

                StatusNavBarTabButton {
                    enabled: isExperimental === "1" || appSettings.nodeManagementEnabled
                    visible: enabled
                    tooltip.text: qsTr("Node Management")
                    icon.name: "node"
                    checked: appView.currentIndex == Utils.getAppSectionIndex(Constants.node)
                    onClicked: appMain.changeAppSection(Constants.node)
                },

                StatusNavBarTabButton {
                    id: profileBtn
                    //% "Settings"
                    tooltip.text: qsTrId("settings")
                    icon.name: "settings"
                    checked: appView.currentIndex == Utils.getAppSectionIndex(Constants.profile)
                    onClicked: appMain.changeAppSection(Constants.profile)

                    badge.visible: !profileModel.mnemonic.isBackedUp
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                    badge.border.width: 2
                }
            ]

            navBarProfileButton: StatusNavBarTabButton {
                id: profileButton
                property bool opened: false
                icon.source: profileModel.profile.thumbnailImage || ""
                badge.visible: true
                badge.anchors.rightMargin: 4
                badge.anchors.topMargin: 25
                badge.implicitHeight: 15
                badge.implicitWidth: 15
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                badge.color: {
                    return profileModel.profile.sendUserStatus ? Style.current.green : Style.current.midGrey
                    /*
                    // Use this code once support for custom user status is added
                    switch(profileModel.profile.currentUserStatus){
                        case Constants.statusType_Online:
                            return Style.current.green;
                        case Constants.statusType_DoNotDisturb:
                            return Style.current.red;
                        default:
                            return Style.current.midGrey;
                    }*/
                }
                badge.border.width: 3
                onClicked: {
                    userStatusContextMenu.opened ?
                        userStatusContextMenu.close() :
                        userStatusContextMenu.open()
                }

                UserStatusContextMenu {
                    id: userStatusContextMenu
                    y: profileButton.y - userStatusContextMenu.height
                }
            }
        }

        appView: StackLayout {
            id: appView
            anchors.fill: parent
            currentIndex: 0
            onCurrentIndexChanged: {
                var obj = this.children[currentIndex];
                if(!obj)
                    return

                if (obj.onActivated && typeof obj.onActivated === "function") {
                    this.children[currentIndex].onActivated()
                }

                if(obj === browserLayoutContainer && browserLayoutContainer.active == false){
                    browserLayoutContainer.active = true;
                }

                timelineLayoutContainer.active = obj === timelineLayoutContainer

                if(obj === walletLayoutContainer){
                    walletLayoutContainer.showSigningPhrasePopup();
                }

                if(obj === walletV2LayoutContainer){
                    walletV2LayoutContainer.showSigningPhrasePopup();
                }
                appSettings.lastModeActiveTab = (currentIndex === Utils.getAppSectionIndex(Constants.timeline)) ? 0 : currentIndex
            }

            ChatLayout {
                id: chatLayoutContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
                onProfileButtonClicked: {
                    appMain.changeAppSection(Constants.profile);
                }
            }

            WalletLayout {
                id: walletLayoutContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
            }

            Component {
                id: browserLayoutComponent
                BrowserLayout { }
            }

            Loader {
                id: browserLayoutContainer
                sourceComponent: browserLayoutComponent
                active: false
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
                // Loaders do not have access to the context, so props need to be set
                // Adding a "_" to avoid a binding loop
                property var _chatsModel: chatsModel.messageView
                property var _walletModel: walletModel
                property var _utilsModel: utilsModel
                property var _web3Provider: web3Provider
            }

            Loader {
                id: timelineLayoutContainer
                sourceComponent: Component {
                    TimelineLayout {}
                }
                onLoaded: timelineLayoutContainer.item.onActivated()
                active: false
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
            }

            ProfileLayout {
                id: profileLayoutContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
            }

            NodeLayout {
                id: nodeLayoutContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
            }

            UIComponents {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
            }

            WalletV2Layout {
                id: walletV2LayoutContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
            }
        }


        Connections {
            target: profileModel

            onSettingsFileChanged: {
                // Since https://github.com/status-im/status-desktop/commit/93668ff75
                // we're hiding the setting to change appearance for compact normal mode
                // of the UI. For now, compact mode is the new default.
                //
                // Prior to this change, most likely many users are still using the
                // normal mode configuration, so we have to enforce compact mode for
                // those.
                if (!appSettings.useCompactMode) {
                    appSettings.useCompactMode = true
                }

                const whitelist = profileModel.getLinkPreviewWhitelist()
                try {
                    const whiteListedSites = JSON.parse(whitelist)
                    let settingsUpdated = false

                    // Add Status links to whitelist
                    whiteListedSites.push({title: "Status", address: Constants.deepLinkPrefix, imageSite: false})
                    whiteListedSites.push({title: "Status", address: Constants.joinStatusLink, imageSite: false})
                    const settings = appSettings.whitelistedUnfurlingSites

                    // Set Status links as true. We intercept thoseURLs so it is privacy-safe
                    if (!settings[Constants.deepLinkPrefix] || !settings[Constants.joinStatusLink]) {
                        settings[Constants.deepLinkPrefix] = true
                        settings[Constants.joinStatusLink] = true
                        settingsUpdated = true
                    }

                    const whitelistedHostnames = []

                    // Add whitelisted sites in to app settings that are not already there
                    whiteListedSites.forEach(site => {
                                                if (!settings.hasOwnProperty(site.address))  {
                                                    settings[site.address] = false
                                                    settingsUpdated = true
                                                }
                                                whitelistedHostnames.push(site.address)
                                            })
                    // Remove any whitelisted sites from app settings that don't exist in the
                    // whitelist from status-go
                    Object.keys(settings).forEach(settingsHostname => {
                        if (!whitelistedHostnames.includes(settingsHostname)) {
                            delete settings[settingsHostname]
                            settingsUpdated = true
                        }
                    })
                    if (settingsUpdated) {
                        appSettings.whitelistedUnfurlingSites = settings
                    }
                } catch (e) {
                    console.error('Could not parse the whitelist for sites', e)
                }
                appMain.settingsLoaded()
            }
        }

        Connections {
            target: chatsModel
            onNotificationClicked: {
                applicationWindow.makeStatusAppActive()

                switch(notificationType){
                case Constants.osNotificationType.newContactRequest:
                    appView.currentIndex = Utils.getAppSectionIndex(Constants.chat)
                    appMain.openContactsPopup()
                    break
                case Constants.osNotificationType.acceptedContactRequest:
                    appView.currentIndex = Utils.getAppSectionIndex(Constants.chat)
                    break
                case Constants.osNotificationType.joinCommunityRequest:
                case Constants.osNotificationType.acceptedIntoCommunity:
                case Constants.osNotificationType.rejectedByCommunity:
                    appView.currentIndex = Utils.getAppSectionIndex(Constants.community)
                    break
                case Constants.osNotificationType.newMessage:
                    appView.currentIndex = Utils.getAppSectionIndex(Constants.chat)
                    break
                }
            }
        }

        Connections {
            target: profileModel
            ignoreUnknownSignals: true
            enabled: removeMnemonicAfterLogin
            onInitialized: {
                profileModel.mnemonic.remove()
            }
        }

        Connections {
            target: profileModel.contacts
            onContactRequestAdded: {
                if (!appSettings.notifyOnNewRequests) {
                    return
                }

                const isContact = profileModel.contacts.isAdded(address)

                // Note:
                // Whole this Connection object should be moved to the nim side.
                // Left here only cause we don't have a way to deal with translations on the nim side.

                //% "Contact request accepted"
                profileModel.showOSNotification(isContact ? qsTrId("contact-request-accepted") :
                                                            //% "New contact request"
                                                            qsTrId("new-contact-request"),
                                                //% "You can now chat with %1"
                                                isContact ? qsTrId("you-can-now-chat-with--1").arg(Utils.removeStatusEns(name)) :
                                                            //% "%1 requests to become contacts"
                                                            qsTrId("-1-requests-to-become-contacts").arg(Utils.removeStatusEns(name)),
                                                isContact? Constants.osNotificationType.acceptedContactRequest :
                                                           Constants.osNotificationType.newContactRequest,
                                                appSettings.useOSNotifications)
            }
        }

        Component {
            id: chooseBrowserPopupComponent
            ChooseBrowserPopup {
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: inviteFriendsToCommunityPopup
            InviteFriendsToCommunityPopup {
                anchors.centerIn: parent
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: communityProfilePopup

            CommunityProfilePopup {
                id: communityProfilePopup
                anchors.centerIn: parent

                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: editCommunityPopup
            CreateCommunityPopup {
                anchors.centerIn: parent
                isEdit: true
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: editChannelPopup
            CreateChannelPopup {
                anchors.centerIn: parent
                isEdit: true
                pinnedMessagesPopupComponent: chatLayoutContainer.chatColumn.pinnedMessagesPopupComponent
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: genericConfirmationDialog
            ConfirmationDialog {
                onClosed: {
                    destroy()
                }
            }
        }

        ToastMessage {
            id: toastMessage
        }
        
        // Add SendModal here as it is used by the Wallet as well as the Browser
        Loader {
            id: sendModal
            active: false
            
            function open() {
                this.active = true
                this.item.open()
            }
            function closed() {
                // this.sourceComponent = undefined // kill an opened instance
                this.active = false
            }
            sourceComponent: SendModal {
                onOpened: {
                    walletModel.gasView.getGasPrice()
                }
                onClosed: {
                    sendModal.closed()
                }
            }
        }

        Action {
            shortcut: "Ctrl+1"
            onTriggered: changeAppSection(Constants.chat)
        }
        Action {
            shortcut: "Ctrl+2"
            onTriggered: changeAppSection(Constants.browser)
        }
        Action {
            shortcut: "Ctrl+3"
            onTriggered: changeAppSection(Constants.wallet)
        }
        Action {
            shortcut: "Ctrl+4, Ctrl+,"
            onTriggered: changeAppSection(Constants.profile)
        }
        Action {
            shortcut: "Ctrl+K"
            onTriggered: {
                if (channelPicker.opened) {
                    channelPicker.close()
                } else {
                    channelPicker.open()
                }
            }
        }

        Component {
            id: statusIdenticonComponent
            StatusIdenticon {}
        }

        StatusInputListPopup {
            id: channelPicker
            //% "Where do you want to go?"
            title: qsTrId("where-do-you-want-to-go-")
            showSearchBox: true
            width: 350
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            modelList: chatsModel.channelView.chats
            getText: function (modelData) {
                return modelData.name
            }
            getImageComponent: function (parent, modelData) {
                return statusIdenticonComponent.createObject(parent, {
                                                                width: channelPicker.imageWidth,
                                                                height: channelPicker.imageHeight,
                                                                chatName: modelData.name,
                                                                chatType: modelData.chatType,
                                                                identicon: modelData.identicon
                                                            });
            }
            onClicked: function (index) {
                appMain.changeAppSection(Constants.chat)
                chatsModel.channelView.setActiveChannelByIndex(index)
                channelPicker.close()
            }
        }
    }

    Component.onCompleted: {
        appView.currentIndex = appSettings.lastModeActiveTab
        if(!!appSettings.lastModeActiveCommunity)
            chatsModel.communities.setActiveCommunity(appSettings.lastModeActiveCommunity)
    }
}
/*##^##
Designer {
    D{i:0;formeditorZoom:1.75;height:770;width:1232}
}
##^##*/
