import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import Qt.labs.qmlmodels 1.0

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import "./AppLayouts"
import "./AppLayouts/Timeline"
import "./AppLayouts/Wallet"
import "./AppLayouts/WalletV2"
import "./AppLayouts/Chat/popups"
import "./AppLayouts/Chat/popups/community"
import "./AppLayouts/Profile/Sections"
import "./AppLayouts/stores"

import Qt.labs.platform 1.1
import Qt.labs.settings 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

Item {
    id: appMain
    anchors.fill: parent

    property alias appLayout: appLayout
    property var newVersionJSON: JSON.parse(utilsModel.newVersion)
    property bool profilePopupOpened: false
    property bool networkGuarded: profileModel.network.current === Constants.networkMainnet || (profileModel.network.current === Constants.networkRopsten && localAccountSensitiveSettings.stickersEnsRopsten)
    property RootStore rootStore: RootStore { }

    signal settingsLoaded()
    signal openContactsPopup()

    function changeAppSectionBySectionType(sectionType) {
        mainModule.setActiveSectionBySectionType(sectionType)
    }

    function changeAppSectionBySectionId(sectionId) {
        mainModule.setActiveSectionById(sectionId)
    }

    function getProfileImage(pubkey, isCurrentUser, useLargeImage) {
        if (isCurrentUser || (isCurrentUser === undefined && pubkey === profileModel.profile.pubKey)) {
            //TODO move profileModule to store
            return profileModule.model.thumbnailImage
        }

        const index = contactsModule.model.list.getContactIndexByPubkey(pubkey)
        if (index === -1) {
            return
        }

        if (localAccountSensitiveSettings.onlyShowContactsProfilePics) {
            const isContact = contactsModule.model.list.rowData(index, "isContact")
            if (isContact === "false") {
                return
            }
        }

        return contactsModule.model.list.rowData(index, useLargeImage ? "largeImage" : "thumbnailImage")
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(appMain, params);
        popup.open()
        return popup
    }

    function getContactListObject(dataModel) {
        const nbContacts = contactsModule.model.list.rowCount()
        const contacts = []
        let contact
        for (let i = 0; i < nbContacts; i++) {
            if (contactsModule.model.list.rowData(i, "isBlocked") === "true") {
                continue
            }

            contact = {
                name: contactsModule.model.list.rowData(i, "name"),
                localNickname: contactsModule.model.list.rowData(i, "localNickname"),
                pubKey: contactsModule.model.list.rowData(i, "pubKey"),
                address: contactsModule.model.list.rowData(i, "address"),
                identicon: contactsModule.model.list.rowData(i, "identicon"),
                thumbnailImage: contactsModule.model.list.rowData(i, "thumbnailImage"),
                isUser: false,
                isContact: contactsModule.model.list.rowData(i, "isContact") !== "false"
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
        const contactList = contactsModule.model.list
        const contactCount = contactList.rowCount()
        for (let i = 0; i < contactCount; i++) {
            if (contactList.rowData(i, 'pubKey') === pubKey) {
                return contactList.rowData(i, 'localNickname')
            }
        }
        return ""
    }

    function openLink(link) {
        if (localAccountSensitiveSettings.showBrowserSelector) {
            appMain.openPopup(chooseBrowserPopupComponent, {link: link})
        } else {
            if (localAccountSensitiveSettings.openLinksInStatus) {
                appMain.changeAppSectionBySectionType(Constants.appSection.browser)
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
        popup.openPopup(profileModule.pubKey !== fromAuthorParam, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam);
        profilePopupOpened = true
    }

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        store: rootStore
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

    AppSearch{
        id: appSearch
        store: mainModule.appSearchModule
    }

    StatusAppLayout {
        id: appLayout

        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: versionWarning.visible ? 32 : 0
        anchors.bottom: parent.bottom

        appNavBar: StatusAppNavBar {
            height: appMain.height

            communityTypeRole: "sectionType"
            communityTypeValue: Constants.appSection.community
            sectionModel: mainModule.sectionsModel

            property bool communityAdded: false

            onAboutToUpdateFilteredRegularModel: {
                communityAdded = false
            }

            filterRegularItem: function(item) {
                if(!item.enabled)
                    return false

                if(item.sectionType === Constants.appSection.community)
                    if(communityAdded)
                        return false
                    else
                        communityAdded = true

                return true
            }

            filterCommunityItem: function(item) {
                return item.sectionType === Constants.appSection.community
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    changeAppSectionBySectionId(model.id)
                }
            }

            communityNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    changeAppSectionBySectionId(model.id)
                }

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
                            store: appMain.rootStore,
                            community: chatsModel.communities.observedCommunity
                        })
                    }

                    StatusMenuItem {
                        enabled: chatsModel.communities.observedCommunity.admin
                        //% "Edit Community"
                        text: qsTrId("edit-community")
                        icon.name: "edit"
                        onTriggered: openPopup(editCommunityPopup, {store: appMain.rootStore, community: chatsModel.communities.observedCommunity})
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

            navBarProfileButton: StatusNavBarTabButton {
                id: profileButton
                property bool opened: false

                icon.source: profileModule.thumbnailImage || ""
                badge.visible: true
                badge.anchors.rightMargin: 4
                badge.anchors.topMargin: 25
                badge.implicitHeight: 15
                badge.implicitWidth: 15
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                badge.color: {
                    return profileModule.sendUserStatus ? Style.current.green : Style.current.midGrey
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
                    store: appMain.rootStore
                }
            }
        }

        appView: StackLayout {
            id: appView
            anchors.fill: parent
            currentIndex: {
                if(mainModule.activeSection.sectionType === Constants.appSection.chat) {
                    return Constants.appViewStackIndex.chat
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.community) {

                    for(let i = this.children.length - 1; i >=0; i--)
                    {
                        var obj = this.children[i];
                        if(obj && obj.sectionId == mainModule.activeSection.id)
                        {
                            return i
                        }
                    }

                    // Should never be here, correct index must be returned from the for loop above
                    console.error("Wrong section type: ", mainModule.activeSection.sectionType,
                                  " or section id: ", mainModule.activeSection.id)
                    return Constants.appViewStackIndex.community
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.wallet) {
                    return Constants.appViewStackIndex.wallet
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.walletv2) {
                    return Constants.appViewStackIndex.walletv2
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.browser) {
                    return Constants.appViewStackIndex.browser
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.timeline) {
                    return Constants.appViewStackIndex.timeline
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.profile) {
                    return Constants.appViewStackIndex.profile
                }
                else if(mainModule.activeSection.sectionType === Constants.appSection.node) {
                    return Constants.appViewStackIndex.node
                }

                // We should never end up here
                console.error("Unknown section type")
            }

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
            }

            // NOTE:
            // If we ever change stack layout component order we need to updade
            // Constants.appViewStackIndex accordingly

            ChatLayout {
                id: chatLayoutContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillHeight: true
                onProfileButtonClicked: {
                    appMain.changeAppSectionBySectionType(Constants.appSection.profile);
                }

                onOpenAppSearch: {
                    appSearch.openSearchPopup()
                }

                Component.onCompleted: {
                    store = mainModule.getChatSectionModule()
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
                BrowserLayout {
                    globalStore: appMain.rootStore
                }
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
                    TimelineLayout {
                        messageStore: appMain.rootStore.messageStore
                        rootStore: appMain.rootStore
                    }
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
                globalStore: appMain.rootStore
            }

            NodeLayout {
                id: nodeLayoutContainer
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

            Repeater{
                model: mainModule.sectionsModel

                delegate: DelegateChooser {
                    id: delegateChooser
                    role: "sectionType"
                    DelegateChoice {
                        roleValue: Constants.appSection.community
                        delegate: ChatLayout {
                            property string sectionId: model.id
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.fillHeight: true

                            onProfileButtonClicked: {
                                appMain.changeAppSectionBySectionType(Constants.appSection.profile);
                            }

                            onOpenAppSearch: {
                                appSearch.openSearchPopup()
                            }

                            Component.onCompleted: {
                                // we cannot return QVariant if we pass another parameter in a function call
                                // that's why we're using it this way
                                mainModule.prepareCommunitySectionModuleForCommunityId(model.id)
                                store = mainModule.getCommunitySectionModule()
                            }
                        }
                    }
                }
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
                if (!localAccountSensitiveSettings.useCompactMode) {
                    localAccountSensitiveSettings.useCompactMode = true
                }

                const whitelist = profileModel.getLinkPreviewWhitelist()
                try {
                    const whiteListedSites = JSON.parse(whitelist)
                    let settingsUpdated = false

                    // Add Status links to whitelist
                    whiteListedSites.push({title: "Status", address: Constants.deepLinkPrefix, imageSite: false})
                    whiteListedSites.push({title: "Status", address: Constants.joinStatusLink, imageSite: false})
                    let settings = localAccountSensitiveSettings.whitelistedUnfurlingSites

                    if (!settings) {
                        settings = {}
                    }

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
                        localAccountSensitiveSettings.whitelistedUnfurlingSites = settings
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
                    appView.currentIndex = Constants.appViewStackIndex.chat
                    appMain.openContactsPopup()
                    break
                case Constants.osNotificationType.acceptedContactRequest:
                    appView.currentIndex = Constants.appViewStackIndex.chat
                    break
                case Constants.osNotificationType.joinCommunityRequest:
                case Constants.osNotificationType.acceptedIntoCommunity:
                case Constants.osNotificationType.rejectedByCommunity:
                    // Not Refactored - Need to check what community exactly we need to switch to.
//                    appView.currentIndex = Utils.getAppSectionIndex(Constants.community)
                    break
                case Constants.osNotificationType.newMessage:
                    appView.currentIndex = Constants.appViewStackIndex.chat
                    break
                }
            }
        }

        Connections {
            target: profileModel
            ignoreUnknownSignals: true
            enabled: removeMnemonicAfterLogin
            onInitialized: {
                mnemonicModule.remove()
            }
        }

        Connections {
            target: contactsModule.model
            onContactRequestAdded: {
                if (!localAccountSensitiveSettings.notifyOnNewRequests) {
                    return
                }

                const isContact = contactsModule.model.isAdded(address)

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
                                                localAccountSensitiveSettings.useOSNotifications)
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
                hasAddedContacts: appMain.rootStore.allContacts.hasAddedContacts()
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: communityProfilePopup

            CommunityProfilePopup {
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
                // Not Refactored
//                pinnedMessagesPopupComponent: chatLayoutContainer.chatColumn.pinnedMessagesPopupComponent
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
                store: appMain.rootStore
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
            onTriggered: changeAppSectionBySectionType(Constants.appSection.chat)
        }
        Action {
            shortcut: "Ctrl+2"
            onTriggered: changeAppSectionBySectionType(Constants.appSection.browser)
        }
        Action {
            shortcut: "Ctrl+3"
            onTriggered: changeAppSectionBySectionType(Constants.appSection.wallet)
        }
        Action {
            shortcut: "Ctrl+4, Ctrl+,"
            onTriggered: changeAppSectionBySectionType(Constants.appSection.profile)
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
            id: statusSmartIdenticonComponent
            StatusSmartIdenticon {
                property  string imageSource: ""
                image: StatusImageSettings {
                    width: channelPicker.imageWidth
                    height: channelPicker.imageHeight
                    source: imageSource
                    isIdenticon: true
                }
                icon: StatusIconSettings {
                    width: channelPicker.imageWidth
                    height: channelPicker.imageHeight
                    letterSize: 15
                    color: Theme.palette.miscColor5
                }
            }
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
                return statusSmartIdenticonComponent.createObject(parent, {
                                                                     imageSource: modelData.identicon,
                                                                     name: modelData.name
                                                            });
            }
            onClicked: function (index) {
                appMain.changeAppSectionBySectionType(Constants.appSection.chat)
                chatsModel.channelView.setActiveChannelByIndex(index)
                channelPicker.close()
            }
        }
    }
}
