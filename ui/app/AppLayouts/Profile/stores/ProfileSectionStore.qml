import QtQuick 2.13
import utils 1.0

import AppLayouts.Chat.stores 1.0

import SortFilterProxyModel 0.2

QtObject {
    id: root

    property string backButtonName

    property var aboutModuleInst: aboutModule
    property var mainModuleInst: mainModule
    property var profileSectionModuleInst: profileSectionModule

    property var sendModalPopup

    readonly property bool fetchingUpdate: !!root.aboutModuleInst? root.aboutModuleInst.fetching : false

    property ContactsStore contactsStore: ContactsStore {
        contactsModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.contactsModule : null
    }

    property AdvancedStore advancedStore: AdvancedStore {
        walletModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.walletModule : null
        advancedModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.advancedModule : null
    }

    property MessagingStore messagingStore: MessagingStore {
        privacyModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.privacyModule : null
        syncModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.syncModule : null
        wakuModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.wakuModule : null
    }

    property DevicesStore devicesStore: DevicesStore {
        devicesModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.devicesModule : null
    }

    property NotificationsStore notificationsStore: NotificationsStore {
        notificationsModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.notificationsModule : null
    }

    property LanguageStore languageStore: LanguageStore {
        languageModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.languageModule : null
    }

    property AppearanceStore appearanceStore: AppearanceStore {
    }

    property ProfileStore profileStore: ProfileStore {
        profileModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.profileModule : null
    }

    property PrivacyStore privacyStore: PrivacyStore {
        privacyModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.privacyModule : null
    }

    property EnsUsernamesStore ensUsernamesStore: EnsUsernamesStore {
        ensUsernamesModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.ensUsernamesModule : null
    }

    property WalletStore walletStore: WalletStore {
        walletModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.walletModule : null
    }

    property KeycardStore keycardStore: KeycardStore {
        keycardModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.keycardModule : null
    }

    property var stickersModuleInst: stickersModule
    property var stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    property bool browserMenuItemEnabled: Global.appIsReady? localAccountSensitiveSettings.isBrowserEnabled : false
    property bool walletMenuItemEnabled: profileStore.isWalletEnabled

    property var communitiesModuleInst: Global.appIsReady? communitiesModule : null
    property var communitiesList: SortFilterProxyModel {
        sourceModel: !!root.mainModuleInst? root.mainModuleInst.sectionsModel : null
        filters: ValueFilter {
            roleName: "sectionType"
            value: Constants.appSection.community
        }
    }
    property var communitiesProfileModule: !!root.profileSectionModuleInst? root.profileSectionModuleInst.communitiesModule : null

    property ListModel mainMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.backUpSeed,
                       text: qsTr("Back up seed phrase"),
                       icon: "seed-phrase"})
            append({subsection: Constants.settingsSubsection.profile,
                       text: qsTr("Profile"),
                       icon: "profile"})
            append({subsection: Constants.settingsSubsection.password,
                       text: qsTr("Password"),
                       icon: "profile"})
            append({subsection: Constants.settingsSubsection.keycard,
                       text: qsTr("Keycard"),
                       icon: "keycard"})
            append({subsection: Constants.settingsSubsection.ensUsernames,
                       text: qsTr("ENS usernames"),
                       icon: "username"})
            append({subsection: Constants.settingsSubsection.syncingSettings,
                       text: qsTr("Syncing"),
                       icon: "rotate"})
        }
    }

    property ListModel appsMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.messaging,
                       text: qsTr("Messaging"),
                       icon: "chat"})
            append({subsection: Constants.settingsSubsection.wallet,
                       text: qsTr("Wallet"),
                       icon: "wallet"})
            append({subsection: Constants.settingsSubsection.browserSettings,
                       text: qsTr("Browser"),
                       icon: "browser"})
            append({subsection: Constants.settingsSubsection.communitiesSettings,
                       text: qsTr("Communities"),
                       icon: "communities"})
        }
    }

    property ListModel settingsMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.appearance,
                       text: qsTr("Appearance"),
                       icon: "appearance"})
            append({subsection: Constants.settingsSubsection.notifications,
                       text: qsTr("Notifications & Sounds"),
                       icon: "notification"})
            append({subsection: Constants.settingsSubsection.language,
                       text: qsTr("Language & Currency"),
                       icon: "language"})
            append({subsection: Constants.settingsSubsection.advanced,
                       text: qsTr("Advanced"),
                       icon: "settings"})
        }
    }

    property ListModel extraMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.about,
                       text: qsTr("About"),
                       icon: "info"})
            append({subsection: Constants.settingsSubsection.signout,
                       text: qsTr("Sign out & Quit"),
                       icon: "logout"})
        }
    }

    function importCommunity(communityKey) {
        root.communitiesModuleInst.importCommunity(communityKey);
    }

    function getCurrentVersion() {
        return aboutModuleInst.getCurrentVersion()
    }

    function getStatusGoVersion() {
        return aboutModuleInst.getStatusGoVersion()
    }

    function nodeVersion() {
        return aboutModuleInst.nodeVersion()
    }

    function checkForUpdates() {
        aboutModuleInst.checkForUpdates()
    }

    function getNameForSubsection(subsection) {
        let i = 0;
        for (; i < mainMenuItems.count; i++) {
            let elem = mainMenuItems.get(i)
            if(elem.subsection === subsection)
                return elem.text
        }

        for (i=0; i < appsMenuItems.count; i++) {
            let elem = appsMenuItems.get(i)
            if(elem.subsection === subsection)
                return elem.text
        }

        for (i=0; i < settingsMenuItems.count; i++) {
            let elem = settingsMenuItems.get(i)
            if(elem.subsection === subsection)
                return elem.text
        }

        for (i=0; i < extraMenuItems.count; i++) {
            let elem = extraMenuItems.get(i)
            if(elem.subsection === subsection)
                return elem.text
        }

        return ""
    }

    function addressWasShown(address) {
        return root.mainModuleInst.addressWasShown(address)
    }
}
