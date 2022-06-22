import QtQuick 2.13
import utils 1.0

import AppLayouts.Chat.stores 1.0

QtObject {
    id: root

    property var aboutModuleInst: aboutModule

    property var profileSectionModuleInst: profileSectionModule

    property bool fetchingUpdate: aboutModule.fetching

    property ContactsStore contactsStore: ContactsStore {
        contactsModule: profileSectionModuleInst.contactsModule
    }

    property AdvancedStore advancedStore: AdvancedStore {
        advancedModule: profileSectionModuleInst.advancedModule
    }

    property MessagingStore messagingStore: MessagingStore {
        privacyModule: profileSectionModuleInst.privacyModule
        syncModule: profileSectionModuleInst.syncModule
    }

    property DevicesStore devicesStore: DevicesStore {
        devicesModule: profileSectionModuleInst.devicesModule
    }

    property NotificationsStore notificationsStore: NotificationsStore {
        notificationsModule: profileSectionModuleInst.notificationsModule
    }

    property LanguageStore languageStore: LanguageStore {
        languageModule: profileSectionModuleInst.languageModule
    }

    property AppearanceStore appearanceStore: AppearanceStore {
    }

    property ProfileStore profileStore: ProfileStore {
        profileModule: profileSectionModuleInst.profileModule
    }

    property PrivacyStore privacyStore: PrivacyStore {
        privacyModule: profileSectionModuleInst.privacyModule
    }

    property EnsUsernamesStore ensUsernamesStore: EnsUsernamesStore {
        ensUsernamesModule: profileSectionModuleInst.ensUsernamesModule
    }

    property WalletStore walletStore: WalletStore {
    }

    property var stickersModuleInst: stickersModule
    property var stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    property bool browserMenuItemEnabled: localAccountSensitiveSettings.isBrowserEnabled
    property bool walletMenuItemEnabled: localAccountSensitiveSettings.isWalletEnabled

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model
    property var communitiesProfileModule: profileSectionModuleInst.communitiesModule

    property ListModel mainMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.backUpSeed,
                       text: qsTr("Back up seed phrase"),
                       icon: "seed-phrase"})
            append({subsection: Constants.settingsSubsection.profile,
                       text: qsTr("Profile"),
                       icon: "profile"})
            append({subsection: Constants.settingsSubsection.ensUsernames,
                       text: qsTr("ENS usernames"),
                       icon: "username"})
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
            append({subsection: Constants.settingsSubsection.devicesSettings,
                       text: qsTr("Devices settings"),
                       icon: "mobile"})
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
}
