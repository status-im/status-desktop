import QtQuick 2.13
import utils 1.0
import SortFilterProxyModel 0.2

QtObject {
    id: root

    property var ensUsernamesModule

    property var ensUsernamesModel: root.ensUsernamesModule ? ensUsernamesModule.model : []

    readonly property QtObject currentChainEnsUsernamesModel: SortFilterProxyModel {
        sourceModel: root.ensUsernamesModel
        filters: ValueFilter {
            roleName: "chainId"
            value: root.chainId
        }
    }

    property string pubkey: !!Global.userProfile? Global.userProfile.pubKey : ""
    property string icon: !!Global.userProfile? Global.userProfile.icon : ""
    property string preferredUsername: !!Global.userProfile? Global.userProfile.preferredName : ""
    readonly property string chainId: ensUsernamesModule.chainId

    property string username: !!Global.userProfile? Global.userProfile.username : ""

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
        return ensUsernamesModule.numOfPendingEnsUsernames()
    }

    function ensDetails(chainId, ensUsername) {
        if(!root.ensUsernamesModule)
            return ""
        ensUsernamesModule.fetchDetailsForEnsUsername(chainId, ensUsername)
    }

    function setPubKeyGasEstimate(chainId, ensUsername, address) {
        if(!root.ensUsernamesModule)
            return 0
        return ensUsernamesModule.setPubKeyGasEstimate(chainId, ensUsername, address)
    }

    function authenticateAndSetPubKey(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.authenticateAndSetPubKey(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)
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

    function authenticateAndReleaseEns(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.authenticateAndReleaseEns(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)
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

    function authenticateAndRegisterEns(chainId, ensUsername, address, gasLimit, gasPrice, tipLimit, overallLimit, eip1559Enabled) {
        if(!root.ensUsernamesModule)
            return
        ensUsernamesModule.authenticateAndRegisterEns(chainId, ensUsername, address, gasLimit, gasPrice, tipLimit, overallLimit, eip1559Enabled)
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

    function getCryptoValue(balance, cryptoSymbol, fiatSymbol) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getCryptoValue(balance, cryptoSymbol, fiatSymbol)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
    }

    function getStatusToken() {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.getStatusToken()
    }

    function removeEnsUsername(chainId, ensUsername) {
        if(!root.ensUsernamesModule)
            return ""
        return ensUsernamesModule.removeEnsUsername(chainId, ensUsername)
    }
}

