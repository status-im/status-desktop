import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var aboutModuleInst: aboutModule

    property var profileSectionModuleInst: profileSectionModule

    property ContactsStore contactsStore: ContactsStore {
        contactsModule: profileSectionModuleInst.contactsModule
    }

    property AdvancedStore advancedStore: AdvancedStore {
        advancedModule: profileSectionModuleInst.advancedModule
    }

    property DevicesStore devicesStore: DevicesStore {
        devicesModule: profileSectionModuleInst.devicesModule
    }

    property SyncStore syncStore: SyncStore {
        syncModule: profileSectionModuleInst.syncModule
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

    property var dappList: dappPermissionsModule.dapps
    property var permissionList: dappPermissionsModule.permissions

    property bool browserMenuItemEnabled: localAccountSensitiveSettings.isBrowserEnabled
    property bool appsMenuItemsEnabled: localAccountSensitiveSettings.isMultiNetworkEnabled

    property ListModel mainMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.profile,
                       text: qsTr("Profile"),
                       icon: "profile"})
            append({subsection: Constants.settingsSubsection.contacts,
                       text: qsTr("Contacts"),
                       icon: "contact"})
            append({subsection: Constants.settingsSubsection.ensUsernames,
                       text: qsTr("ENS usernames"),
                       icon: "username"})
        }
    }

    property ListModel appsMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.wallet,
                       text: qsTr("Wallet"),
                       icon: "wallet"})
            append({subsection: Constants.settingsSubsection.browserSettings,
                       text: qsTr("Browser"),
                       icon: "browser"})
        }
    }

    property ListModel settingsMenuItems: ListModel {
        Component.onCompleted: {
            append({subsection: Constants.settingsSubsection.privacyAndSecurity,
                       text: qsTr("Privacy and security"),
                       icon: "security"})
            append({subsection: Constants.settingsSubsection.appearance,
                       text: qsTr("Appearance"),
                       icon: "appearance"})
            append({subsection: Constants.settingsSubsection.sound,
                       text: qsTr("Sound"),
                       icon: "sound"})
            append({subsection: Constants.settingsSubsection.language,
                       text: qsTr("Language"),
                       icon: "language"})
            append({subsection: Constants.settingsSubsection.notifications,
                       text: qsTr("Notifications"),
                       icon: "notification"})
            append({subsection: Constants.settingsSubsection.syncSettings,
                       text: qsTr("Sync settings"),
                       icon: "mobile"})
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
            append({subsection: Constants.settingsSubsection.needHelp,
                       text: qsTr("Help & Glossary"),
                       icon: "help"})
            append({subsection: Constants.settingsSubsection.about,
                       text: qsTr("About"),
                       icon: "info"})
            append({subsection: Constants.settingsSubsection.signout,
                       text: qsTr("Sign out & Quit"),
                       icon: "logout"})
        }
    }

    function initPermissionList(name) {
        dappPermissionsModule.fetchPermissions(name)
    }

    function revokePermission(dapp, name) {
        dappPermissionsModule.revokePermission(dapp, name)
    }

    function clearPermissions(dapp) {
        dappPermissionsModule.clearPermissions(dapp)
    }

    function initDappList() {
        dappPermissionsModule.fetchDapps()
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
}
