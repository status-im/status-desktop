import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var profileModelInst: profileModel
    property var profileModuleInst: profileSectionModule
    property var profile: profileModule
    property var contactsModuleInst: contactsModule
    property var aboutModuleInst: aboutModule
    property var languageModuleInst: languageModule
    property var mnemonicModuleInst: mnemonicModule

    property var chatsModelInst: chatsModel
    property var utilsModelInst: utilsModel
    property var walletModelInst: walletModel
    property var nodeModelInst: nodeModel

    property var ens: profileModelInst.ens
    property var dappList: dappPermissionsModule.dapps
    property var permissionList: dappPermissionsModule.permissions
    property var mailservers: profileModelInst.mailservers
    property var mailserversList: profileModelInst.mailservers.list
    property var contacts: contactsModuleInst.model.list
    property var blockedContacts: contactsModuleInst.model.blockedContacts
    property var addedContacts: contactsModuleInst.model.addedContacts
    property var mutedChatsContacts: profileModelInst.mutedChats.contacts
    property var mutedChats: profileModelInst.mutedChats.chats
    property var devicesList: profileModelInst.devices.list

    property string ensRegisterAddress: utilsModelInst.ensRegisterAddress
    property string etherscanLink: walletModelInst.utilsView.etherscanLink
    property string pubKey: profile.pubKey
    property string fleet: profileModelInst.fleets.fleet
    property string bloomLevel: nodeModelInst.bloomLevel
    property string currentNetwork: profileModelInst.network.current
    property string preferredUsername: profileModelInst.ens.preferredUsername
    property string firstEnsUsername: profileModelInst.ens.firstEnsUsername
    property string username: profile.username
    property string identicon: profile.identicon
    property string profileLargeImage: profile.largeImage
    property string profileThumbnailImage: profile.thumbnailImage

    property bool profileHasIdentityImage: profile.hasIdentityImage
    property bool automaticMailserverSelection: profileModelInst.mailservers.automaticSelection
    property bool isWakuV2LightClient: nodeModelInst.WakuV2LightClient
    property bool devicesSetup: profileModelInst.devices.isSetup
    property bool mnemonicBackedUp: mnemonicModuleInst.isBackedUp
    property bool messagesFromContactsOnly: profile.messagesFromContactsOnly

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
    property int selectedMenuItem: 0

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

    function getQrCodeSource(publicKey) {
        return profileModelInst.qrCode(publicKey)
    }

    function copyToClipboard(value) {
        chatsModelInst.copyToClipboard(value)
    }

    function uploadImage(source, aX, aY, bX, bY) {
        return profileModelInst.picture.upload(source, aX, aY, bX, bY)
    }

    function removeImage() {
        return profileModelInst.picture.remove()
    }

    function lookupContact(value) {
        console.log('lookup ples', value, profileModelInst)
        contactsModuleInst.lookupContact(value)
    }

    function addContact(pubKey) {
        contactsModuleInst.addContact(pubKey)
    }

    function generateAlias(pubKey) {
        return utilsModelInst.generateAlias(pubKey)
    }

    function changeAppSection(section) {
        appMain.changeAppSection(section)
    }

    function joinPrivateChat(address) {
        chatsModelInst.channelView.joinPrivateChat(address, "");
    }

    function unblockContact(address) {
        contactsModuleInst.unblockContact(address)
    }

    function blockContact(address) {
        contactsModuleInst.blockContact(address)
    }

    function isContactAdded(address) {
        return contactsModuleInst.model.isAdded(address)
    }

    function removeContact(address) {
        contactsModuleInst.removeContact(address)
    }

    function ensDetails(username) {
        profileModelInst.ens.details(username)
    }

    function ensPendingLen() {
        return profileModelInst.ens.pendingLen()
    }

    function validateEns(ensName, isStatus) {
        profileModelInst.ens.validate(ensName, isStatus)
    }

    function registerEnsGasEstimate(username, address) {
        return profileModelInst.ens.registerENSGasEstimate(username, address)
    }

    function registerEns(username, address, gasLimit, tipLimit, overallLimit, gasPrice, password) {
        return profileModelInst.ens.registerENS(username,
            address, gasLimit, tipLimit, overallLimit, gasPrice, password)
    }

    function getEnsUsernameRegistrar() {
         return profileModelInst.ens.getUsernameRegistrar()
    }

    function getEnsRegistry() {
        return profileModelInst.ens.getENSRegistry()
    }

    function releaseEnsEstimate(username, address) {
        return profileModelInst.ens.releaseEstimate(username, address)
    }

    function releaseEns(username, address, gasLimit, gasPrice, password) {
        return profileModelInst.ens.release(username, address, gasLimit, gasPrice, password)
    }

    function getGasPrice() {
        walletModelInst.gasView.getGasPrice()
    }

    function getGasPricePredictions() {
        walletModelInst.gasView.getGasPricePredictions()
    }

    function ensConnectOwnedUsername(name, isStatus) {
        profileModelInst.ens.connectOwnedUsername(name, isStatus)
    }

    function getWalletDefaultAddress() {
        return walletModelInst.getDefaultAddress()
    }

    function getSntBalance() {
        return utilsModelInst.getSNTBalance()
    }

    function changeLocale(l) {
        languageModuleInst.changeLocale(l)
    }

    function getMailserverName(mailserver) {
        return profileModelInst.mailservers.list.getMailserverName(mailserver)
    }

    function setMailserver(mailserver) {
        profileModelInst.mailservers.setMailserver(mailserver);
    }

    function saveMailserver(name, enode) {
        profileModelInst.mailservers.save(name, enode)
    }

    function enableAutomaticMailserverSelection(checked) {
        profileModelInst.mailservers.enableAutomaticSelection(checked)
    }

    function getNetworkName() {
        return utilsModelInst.getNetworkName()
    }

    function logDir() {
        return profileModelInst.logDir()
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
        utilsModelInst.checkForUpdates()
    }

    function setPubKeyGasEstimate(username, address) {
        return profileModelInst.ens.setPubKeyGasEstimate(username, address)
    }

    function setPubKey(username, address, gasLimit, gasPrice, password) {
        return profileModelInst.ens.setPubKey(username, address, gasLimit, gasPrice, password)
    }

    function setDeviceName(name) {
        profileModelInst.devices.setName(name)
    }

    function advertiseDevice() {
        profileModelInst.devices.advertise()
    }

    function enableDeviceInstallation(id, pairedSwitch) {
        profileModelInst.devices.enableInstallation(id, pairedSwitch)
    }

    function syncAllDevices() {
        profileModelInst.devices.syncAll()
    }

    function readTextFile(path) {
        return utilsModelInst.readTextFile(path)
    }

    function writeTextFile(path, value) {
        utilsModelInst.writeTextFile(path, value)
    }

    function setMessagesFromContactsOnly(checked) {
        profileModelInst.setMessagesFromContactsOnly(checked)
    }
}
