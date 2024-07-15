import QtQuick 2.14

QtObject {
    id: root

    property var startupModuleInst: startupModule
    property var currentStartupState: startupModuleInst ? startupModuleInst.currentStartupState
                                                        : null
    property var selectedLoginAccount: startupModuleInst ? startupModuleInst.selectedLoginAccount
                                                         : null
    property var fetchingDataModel: startupModuleInst ? startupModuleInst.fetchingDataModel
                                                         : null

    readonly property int localPairingState: startupModuleInst ? startupModuleInst.localPairingState : -1
    readonly property string localPairingError: startupModuleInst ? startupModuleInst.localPairingError : ""
    readonly property string localPairingName: startupModuleInst ? startupModuleInst.localPairingName : ""
    readonly property string localPairingImage: startupModuleInst ? startupModuleInst.localPairingImage : ""
    readonly property int localPairingColorId: startupModuleInst ? startupModuleInst.localPairingColorId : 0
    readonly property string localPairingColorHash: startupModuleInst ? startupModuleInst.localPairingColorHash : ""
    readonly property string localPairingInstallationId: startupModuleInst ? startupModuleInst.localPairingInstallationId : ""
    readonly property string localPairingInstallationName: startupModuleInst ? startupModuleInst.localPairingInstallationName : ""
    readonly property string localPairingInstallationDeviceType: startupModuleInst ? startupModuleInst.localPairingInstallationDeviceType : ""
    readonly property bool notificationsNeedsEnable: startupModuleInst ? startupModuleInst.notificationsNeedsEnable : false

    function backAction() {
        root.currentStartupState.backAction()
    }

    function doPrimaryAction() {
        root.currentStartupState.doPrimaryAction()
    }

    function doSecondaryAction() {
        root.currentStartupState.doSecondaryAction()
    }

    function doTertiaryAction() {
        root.currentStartupState.doTertiaryAction()
    }

    function doQuaternaryAction() {
        root.currentStartupState.doQuaternaryAction()
    }

    function doQuinaryAction() {
        root.currentStartupState.doQuinaryAction()
    }

    function showBeforeGetStartedPopup() {
        return root.startupModuleInst.showBeforeGetStartedPopup()
    }

    function beforeGetStartedPopupAccepted() {
        root.startupModuleInst.beforeGetStartedPopupAccepted()
    }

    function generateImage(source, aX, aY, bX, bY) {
        return root.startupModuleInst.generateImage(source, aX, aY, bX, bY)
    }

    function getCroppedProfileImage() {
        return root.startupModuleInst.getCroppedProfileImage()
    }

    function setDisplayName(value) {
        root.startupModuleInst.setDisplayName(value)
    }

    function getDisplayName() {
        return root.startupModuleInst.getDisplayName()
    }

    function setPassword(value) {
        root.startupModuleInst.setPassword(value)
    }

    function setDefaultWalletEmoji(emoji) {
        root.startupModuleInst.setDefaultWalletEmoji(emoji)
    }

    function getPassword() {
        return root.startupModuleInst.getPassword()
    }

    function setPin(value) {
        root.startupModuleInst.setPin(value)
    }

    function getPin() {
        return root.startupModuleInst.getPin()
    }

    function setPuk(value) {
        root.startupModuleInst.setPuk(value)
    }

    function getPasswordStrengthScore(password) {
        let userName = root.startupModuleInst.importedAccountAlias
        return root.startupModuleInst.getPasswordStrengthScore(password, userName)
    }

    function validMnemonic(mnemonic) {
        return root.startupModuleInst.validMnemonic(mnemonic)
    }

    function setSelectedLoginAccountByIndex(index) {
        root.startupModuleInst.setSelectedLoginAccountByIndex(index)
    }

    function checkRepeatedKeycardPinWhileTyping(pin) {
        return root.startupModuleInst.checkRepeatedKeycardPinWhileTyping(pin)
    }

    function getSeedPhrase() {
        return root.startupModuleInst.getSeedPhrase()
    }

    function validateLocalPairingConnectionString(connectionString) {
        return root.startupModuleInst.validateLocalPairingConnectionString(connectionString)
    }

    function setConnectionString(connectionString) {
        root.startupModuleInst.setConnectionString(connectionString)
    }
}
