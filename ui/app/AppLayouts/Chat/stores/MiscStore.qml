import QtQuick 2.15

import SortFilterProxyModel 0.2

import StatusQ 0.1

import AppLayouts.Profile.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore
import shared.stores 1.0

// Just temp to track the code that needs to be allocated on a different domain (wallet / profile)
QtObject {
    id: root

    property ContactsStore contactsStore
    property WalletStore.RootStore walletStore
    property CurrenciesStore currencyStore
    property NetworkConnectionStore networkConnectionStore

    readonly property var walletCollectiblesModel: ObjectProxyModel {

        sourceModel: WalletStore.RootStore.collectiblesStore.allCollectiblesModel

        delegate: QtObject {
            readonly property string key: model.symbol ?? ""
            readonly property string shortName: model.collectionName ? model.collectionName : model.collectionUid ? model.collectionUid : ""
            readonly property string symbol: shortName
            readonly property string name: shortName
            readonly property int category: 1 // Own
        }

        exposedRoles: ["key", "symbol", "shortName", "name", "category"]
        expectedRoles: ["symbol", "collectionName", "collectionUid"]
    }

    readonly property var walletCollectiblesGroupingModel: GroupingModel {
        sourceModel: walletCollectiblesModel

        groupingRoleName: "collectionUid"
        submodelRoleName: "subnames"
    }

    readonly property var walletNonCommunityCollectiblesModel: SortFilterProxyModel {
        sourceModel: walletCollectiblesGroupingModel

        filters: ValueFilter {
            roleName: "communityId"
            value: ""
        }
    }

    property var walletCollectiblesWithIconSourceModel: RolesRenamingModel {
        sourceModel: walletNonCommunityCollectiblesModel

        mapping: RoleRename {
            from: "mediaUrl"
            to: "iconSource"
        }
    }

    property var collectiblesModel: ConcatModel {
        sources: [
            SourceModel {
                model: communityCollectiblesModelWithCollectionRoles
            },
            SourceModel {
                model: walletCollectiblesWithIconSourceModel
            }
        ]
    }

    // Contact requests related part
    property var contactRequestsModel: chatCommunitySectionModule.contactRequestsModel

    property var advancedModule: profileSectionModule.advancedModule

    property var privacyModule: profileSectionModule.privacyModule

    function acceptContactRequest(pubKey, contactRequestId) {
        chatCommunitySectionModule.acceptContactRequest(pubKey, contactRequestId)
    }

    function acceptAllContactRequests() {
        chatCommunitySectionModule.acceptAllContactRequests()
    }

    function dismissContactRequest(pubKey, contactRequestId) {
        chatCommunitySectionModule.dismissContactRequest(pubKey, contactRequestId)
    }

    function dismissAllContactRequests() {
        chatCommunitySectionModule.dismissAllContactRequests()
    }

    function blockContact(pubKey) {
        chatCommunitySectionModule.blockContact(pubKey)
    }

    property var globalUtilsInst: globalUtils

    property var mainModuleInst: mainModule

    readonly property string appNetworkId: mainModuleInst.appNetworkId

    property var walletSectionSendInst: walletSectionSend


    property var stickersModuleInst: stickersModule

    property bool isDebugEnabled: advancedModule ? advancedModule.isDebugEnabled : false

    readonly property int loginType: getLoginType()



    property StickersStore stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    function sendSticker(channelId, hash, replyTo, pack, url) {
        stickersModuleInst.send(channelId, hash, replyTo, pack, url)
    }

    // Needed for TX in chat for stickers and via contact
    readonly property var accounts: walletSectionAccounts.accounts
    property string currentCurrency: walletSection.currentCurrency
    property var savedAddressesModel: walletSectionSavedAddresses.model

    property var disabledChainIdsFromList: []
    property var disabledChainIdsToList: []

    function addRemoveDisabledFromChain(chainID, isDisabled) {
        if(isDisabled) {
            disabledChainIdsFromList.push(chainID)
        }
        else {
            for(var i = 0; i < disabledChainIdsFromList.length;i++) {
                if(disabledChainIdsFromList[i] === chainID) {
                    disabledChainIdsFromList.splice(i, 1)
                }
            }
        }
    }

    function addRemoveDisabledToChain(chainID, isDisabled) {
        if(isDisabled) {
            disabledChainIdsToList.push(chainID)
        }
        else {
            for(var i = 0; i < disabledChainIdsToList.length;i++) {
                if(disabledChainIdsToList[i] === chainID) {
                    disabledChainIdsToList.splice(i, 1)
                }
            }
        }
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionModule.ensUsernamesModule.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function acceptRequestTransaction(transactionHash, messageId, signature) {
        return currentChatContentModule().inputAreaModule.acceptRequestTransaction(transactionHash, messageId, signature)
    }

    function acceptAddressRequest(messageId, address) {
        currentChatContentModule().inputAreaModule.acceptAddressRequest(messageId, address)
    }

    function declineAddressRequest(messageId) {
        currentChatContentModule().inputAreaModule.declineAddressRequest(messageId)
    }

    function declineRequest(messageId) {
        currentChatContentModule().inputAreaModule.declineRequest(messageId)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionModule.ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
    }

    function resolveENS(value) {
        mainModuleInst.resolveENS(value, "")
    }

    function getWei2Eth(wei) {
        return globalUtilsInst.wei2Eth(wei,18)
    }

    function getEtherscanTxLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanTxLink()
    }

    function getLoginType() {
        if(!d.userProfileInst)
            return Constants.LoginType.Password

        if(d.userProfileInst.usingBiometricLogin)
            return Constants.LoginType.Biometrics
        if(d.userProfileInst.isKeycardUser)
            return Constants.LoginType.Keycard
        return Constants.LoginType.Password
    }
}
