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

    property int profile_id: 0
    property int contacts_id: 1
    property int ens_id: 2
    property int wallet_id: 3
    property int privacy_and_security_id: 4
    property int appearance_id: 5
    property int sound_id: 6
    property int language_id: 7
    property int notifications_id: 8
    property int sync_settings_id: 9
    property int devices_settings_id: 10
    property int browser_settings_id: 11
    property int advanced_id: 12
    property int need_help_id: 13
    property int about_id: 14
    property int signout_id: 15

    property bool browserMenuItemEnabled: localAccountSensitiveSettings.isBrowserEnabled
    property bool appsMenuItemsEnabled: localAccountSensitiveSettings.isMultiNetworkEnabled

    property ListModel mainMenuItems: ListModel {
        ListElement {
            menu_id: 0
            text: qsTr("My Profile")
            icon: "profile"
        }
        ListElement {
            menu_id: 1
            text: qsTr("Contacts")
            icon: "contact"
        }
        ListElement {
            menu_id: 2
            text: qsTr("ENS usernames")
            icon: "username"
        }
    }

    property ListModel appsMenuItems: ListModel {
        ListElement {
            menu_id: 3
            text: qsTr("Wallet")
            icon: "wallet"
        }
    }

    property ListModel settingsMenuItems: ListModel {
        ListElement {
            menu_id: 4
            text: qsTr("Privacy and security")
            icon: "security"
        }
        ListElement {
            menu_id: 5
            text: qsTr("Appearance")
            icon: "appearance"
        }
        ListElement {
            menu_id: 6
            text: qsTr("Sound")
            icon: "sound"
        }
        ListElement {
            menu_id: 7
            text: qsTr("Language")
            icon: "language"
        }
        ListElement {
            menu_id: 8
            text: qsTr("Notifications")
            icon: "notification"
        }
        ListElement {
            menu_id: 9
            text: qsTr("Sync settings")
            icon: "mobile"
        }
        ListElement {
            menu_id: 10
            text: qsTr("Devices settings")
            icon: "mobile"
        }
        ListElement {
            menu_id: 11
            text: qsTr("Browser settings")
            icon: "browser"
            ifEnabled: "browser"
        }
        ListElement {
            menu_id: 12
            text: qsTr("Advanced")
            icon: "settings"
        }
    }

    property ListModel extraMenuItems: ListModel {
        ListElement {
            menu_id: 13
            text: qsTr("Need help?")
            icon: "help"
        }
        ListElement {
            menu_id: 14
            text: qsTr("About")
            icon: "info"
        }
        ListElement {
            menu_id: 15
            function_name: "exit"
            text: qsTr("Sign out & Quit")
            icon: "logout"
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
