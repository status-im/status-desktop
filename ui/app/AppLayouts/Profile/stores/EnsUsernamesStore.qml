import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var ensUsernamesModule

    property var ensUsernamesModel: root.ensUsernamesModule ? ensUsernamesModule.model : []

    property string pubkey: userProfile.pubKey
    property string icon: userProfile.icon
    property string preferredUsername: userProfile.preferredName

    property string username: userProfile.username

    property var walletAccounts: walletSectionAccounts.model

    function setPrefferedEnsUsername(ensName) {
        if(!root.ensUsernamesModule)
            return
        ensUsernamesModule.setPrefferedEnsUsername(ensName)
    }

    function checkEnsUsernameAvailability(ensName, isStatus) {
        if(!root.ensUsernamesModule)
            return
        ensUsernamesModule.checkEnsUsernameAvailability(ensName, isStatus)
    }

    function numOfPendingEnsUsernames() {
        if(!root.ensUsernamesModule)
            return 0
        ensUsernamesModule.numOfPendingEnsUsernames()
    }

    function ensDetails(ensUsername) {
        if(!root.ensUsernamesModule)
            return ""
        ensUsernamesModule.fetchDetailsForEnsUsername(ensUsername)
    }

    function setPubKeyGasEstimate(ensUsername, address) {
        if(!root.ensUsernamesModule)
            return 0
        return ensUsernamesModule.setPubKeyGasEstimate(ensUsername, address)
    }

    function authenticateAndSetPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.authenticateAndSetPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)
    }

    function getEtherscanLink() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getEtherscanLink()
    }

    function getSigningPhrase() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getSigningPhrase()
    }

    function copyToClipboard(value) {
        globalUtils.copyToClipboard(value)
    }

    function authenticateAndReleaseEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.authenticateAndReleaseEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)
    }

    function ensConnectOwnedUsername(name, isStatus) {
        if(!root.ensUsernamesModule)
            return
        ensUsernamesModule.connectOwnedUsername(name, isStatus)
    }

    function getEnsRegisteredAddress() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getEnsRegisteredAddress()
    }

    function authenticateAndRegisterEns(ensUsername, address, gasLimit, gasPrice, tipLimit, overallLimit, eip1559Enabled) {
        if(!root.ensUsernamesModule)
            return
        ensUsernamesModule.authenticateAndRegisterEns(ensUsername, address, gasLimit, gasPrice, tipLimit, overallLimit, eip1559Enabled)
    }

    function getEnsRegistry() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getEnsRegistry()
    }

    function getSntBalance() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getSNTBalance()
    }

    function getWalletDefaultAddress() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getWalletDefaultAddress()
    }

    function getCurrentCurrency() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getCurrentCurrency()
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
    }

    function getEstimatedTime(chainId, maxFeePerGas) {
       return walletSectionTransactions.getEstimatedTime(chainId, maxFeePerGas)
    }

    function getStatusToken() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getStatusToken()
    }

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionTransactions.suggestedFees(chainId))
    }

    function getChainIdForEns() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getChainIdForEns()
    }
}

