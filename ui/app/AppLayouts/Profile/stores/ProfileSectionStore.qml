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

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var utilsModelInst: utilsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    // Not Refactored Yet
//    property var nodeModelInst: nodeModel

    // Not Refactored Yet
//    property var ens: profileModelInst.ens
    property var dappList: dappPermissionsModule.dapps
    property var permissionList: dappPermissionsModule.permissions
    // Not Refactored Yet
//    property var mutedChatsContacts: profileModelInst.mutedChats.contacts
//    property var mutedChats: profileModelInst.mutedChats.chats

    // Not Refactored Yet
    property string ensRegisterAddress: "" //utilsModelInst.ensRegisterAddress
    // Not Refactored Yet
    property string etherscanLink: "" //walletModelInst.utilsView.etherscanLink
    // Not Refactored Yet
//    property string preferredUsername: userProfile.preferredName // was:  profileModelInst.ens.preferredUsername
//    property string firstEnsUsername: userProfile.firstEnsName // was: profileModelInst.ens.firstEnsUsername

    property int profile_id: 0
    property int contacts_id: 1
    property int ens_id: 2
    property int privacy_and_security_id: 3
    property int appearance_id: 4
    property int sound_id: 5
    property int language_id: 6
    property int notifications_id: 7
    property int sync_settings_id: 8
    property int devices_settings_id: 9
    property int browser_settings_id: 10
    property int advanced_id: 11
    property int need_help_id: 12
    property int about_id: 13
    property int signout_id: 14

    property bool browserMenuItemEnabled: localAccountSensitiveSettings.isBrowserEnabled

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

    property ListModel settingsMenuItems: ListModel {
        ListElement {
            menu_id: 3
            text: qsTr("Privacy and security")
            icon: "security"
        }
        ListElement {
            menu_id: 4
            text: qsTr("Appearance")
            icon: "appearance"
        }
        ListElement {
            menu_id: 5
            text: qsTr("Sound")
            icon: "sound"
        }
        ListElement {
            menu_id: 6
            text: qsTr("Language")
            icon: "language"
        }
        ListElement {
            menu_id: 7
            text: qsTr("Notifications")
            icon: "notification"
        }
        ListElement {
            menu_id: 8
            text: qsTr("Sync settings")
            icon: "mobile"
        }
        ListElement {
            menu_id: 9
            text: qsTr("Devices settings")
            icon: "mobile"
        }
        ListElement {
            menu_id: 10
            text: qsTr("Browser settings")
            icon: "browser"
            ifEnabled: "browser"
        }
        ListElement {
            menu_id: 11
            text: qsTr("Advanced")
            icon: "settings"
        }
    }

    property ListModel extraMenuItems: ListModel {
        ListElement {
            menu_id: 12
            text: qsTr("Need help?")
            icon: "help"
        }
        ListElement {
            menu_id: 13
            text: qsTr("About")
            icon: "info"
        }
        ListElement {
            menu_id: 14
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

    function ensDetails(username) {
        // Not Refactored Yet
//        profileModelInst.ens.details(username)
    }

    function ensPendingLen() {
        // Not Refactored Yet
//        return profileModelInst.ens.pendingLen()
    }

    function validateEns(ensName, isStatus) {
        // Not Refactored Yet
//        profileModelInst.ens.validate(ensName, isStatus)
    }

    function registerEnsGasEstimate(username, address) {
        // Not Refactored Yet
//        return profileModelInst.ens.registerENSGasEstimate(username, address)
    }

    function registerEns(username, address, gasLimit, tipLimit, overallLimit, gasPrice, password) {
        // Not Refactored Yet
//        return profileModelInst.ens.registerENS(username,
//            address, gasLimit, tipLimit, overallLimit, gasPrice, password)
    }

    function getEnsUsernameRegistrar() {
        // Not Refactored Yet
//         return profileModelInst.ens.getUsernameRegistrar()
    }

    function getEnsRegistry() {
        // Not Refactored Yet
//        return profileModelInst.ens.getENSRegistry()
    }

    function releaseEnsEstimate(username, address) {
        // Not Refactored Yet
//        return profileModelInst.ens.releaseEstimate(username, address)
    }

    function releaseEns(username, address, gasLimit, gasPrice, password) {
        // Not Refactored Yet
//        return profileModelInst.ens.release(username, address, gasLimit, gasPrice, password)
    }

    function getGasPrice() {
        // Not Refactored Yet
//        walletModelInst.gasView.getGasPrice()
    }

    function getGasPricePredictions() {
        // Not Refactored Yet
//        walletModelInst.gasView.getGasPricePredictions()
    }

    function ensConnectOwnedUsername(name, isStatus) {
        // Not Refactored Yet
//        profileModelInst.ens.connectOwnedUsername(name, isStatus)
    }

    function getWalletDefaultAddress() {
        // Not Refactored Yet
//        return walletModelInst.getDefaultAddress()
    }

    function getSntBalance() {
        // Not Refactored Yet - This should be fetched from corresponding module, not from the global Utils
//        return utilsModelInst.getSNTBalance()
    }

    function getNetworkName() {
        // Not Refactored Yet
//        return utilsModelInst.getNetworkName()
    }

    function setBloomLevel(mode) {
        nodeModelInst.setBloomLevel(mode)
    }

    function setWakuV2LightClient(mode) {
        nodeModelInst.setWakuV2LightClient(mode)
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

    function setPubKeyGasEstimate(username, address) {
        // Not Refactored Yet
//        return profileModelInst.ens.setPubKeyGasEstimate(username, address)
    }

    function setPubKey(username, address, gasLimit, gasPrice, password) {
        // Not Refactored Yet
//        return profileModelInst.ens.setPubKey(username, address, gasLimit, gasPrice, password)
    }

    function userNameOrAlias(pk) {
        // Not Refactored Yet
//        return chatsModelInst.userNameOrAlias(pk);
    }

    function generateIdenticon(pk) {
        // Not Refactored Yet
//        return utilsModelInst.generateIdenticon(pk);
    }
}
