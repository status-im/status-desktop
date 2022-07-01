import QtQuick 2.13

import "../Profile/stores"

QtObject {
    id: root

    property string locale: localAppSettings.locale

    property var mainModuleInst: mainModule
    property var aboutModuleInst: aboutModule
    property var communitiesModuleInst: communitiesModule
    property var observedCommunity: communitiesModuleInst.observedCommunity

    property bool newVersionAvailable: false
    property string latestVersion
    property string downloadURL

    function setLatestVersionInfo(newVersionAvailable, latestVersion, downloadURL) {
        root.newVersionAvailable = newVersionAvailable;
        root.latestVersion = latestVersion;
        root.downloadURL = downloadURL;
    }

    function resetLastVersion(){
        root.newVersionAvailable = false
    }

    property AppSearchStore appSearchStore: AppSearchStore {
        appSearchModule: root.mainModuleInst.appSearchModule
    }

    property ProfileSectionStore profileSectionStore: ProfileSectionStore {
    }

    property EmojiReactions emojiReactionsModel: EmojiReactions {
    }

    property var chatSearchModel: mainModuleInst.chatSearchModel

    function rebuildChatSearchModel() {
        mainModuleInst.rebuildChatSearchModel()
    }

    function setActiveSectionChat(sectionId, chatId) {
        mainModuleInst.switchTo(sectionId, chatId)
    }

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    property var userProfileInst: userProfile

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    // Not Refactored Yet
//    property var profileModelInst: profileModel

    property var contactStore: profileSectionStore.contactsStore
    property var privacyStore: profileSectionStore.privacyStore
    property var messagingStore: profileSectionStore.messagingStore
    property bool hasAddedContacts: contactStore.myContactsModel.count > 0

//    property MessageStore messageStore: MessageStore { }

    property real volume: !!localAccountSensitiveSettings ? localAccountSensitiveSettings.volume * 0.01 : 0.5
    property bool notificationSoundsEnabled: !!localAccountSensitiveSettings ? localAccountSensitiveSettings.notificationSoundsEnabled : false

    property var walletSectionTransactionsInst: walletSectionTransactions

    property var savedAddressesModel: walletSectionSavedAddresses.model

    property var allNetworks: networksModule.all

    property var disabledChainIds: []

    function addRemoveDisabledChain(suggestedRoutes, chainID, isDisbaled) {
        if(isDisbaled) {
            disabledChainIds.push(chainID)
        }
        else {
            for(var i = 0; i < disabledChainIds.length;i++) {
                if(disabledChainIds[i] === chainID) {
                    disabledChainIds.splice(i, 1)
                }
            }
        }
    }

    function checkIfDisabledByUser(chainID) {
        for(var i = 0; i < disabledChainIds.length;i++) {
            if(disabledChainIds[i] === chainID) {
                return true
            }
        }
        return false
    }

    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
    }

    function createCommunity(communityName, communityDescription, checkedMembership, communityColor, communityTags,
                             communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        communitiesModuleInst.createCommunity(communityName, communityDescription, checkedMembership, communityColor,
                                              communityTags, communityImage, imageCropperModalaX, imageCropperModalaY,
                                              imageCropperModalbX, imageCropperModalbY);
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function generateAlias(pk) {
        return globalUtils.generateAlias(pk);
    }

    property string currentCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase
    function estimateGas(from_addr, to, assetSymbol, value, chainId, data) {
        return walletSectionTransactions.estimateGas(from_addr, to, assetSymbol, value, chainId, data)
    }
    function getFiatValue(balance, cryptoSymbo, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getFiatValue(balance, cryptoSymbo, fiatSymbol)
    }
    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionStore.ensUsernamesStore.getGasEthValue(gweiValue, gasLimit)
    }


    function transfer(from, to, tokenSymbol, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, chainId, uuid, eip1559Enabled) {
        return walletSectionTransactions.transfer(
            from, to, tokenSymbol, amount, gasLimit,
            gasPrice, tipLimit, overallLimit, password, chainId, uuid,
            eip1559Enabled
        );
    }

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionTransactions.suggestedFees(chainId))
    }

    function getEstimatedTime(chainId, maxFeePerGas) {
       return walletSectionTransactions.getEstimatedTime(chainId, maxFeePerGas)
    }

    function getChainIdForChat() {
        return walletSectionTransactions.getChainIdForChat()
    }

    function getChainIdForBrowser() {
        return walletSectionTransactions.getChainIdForBrowser()
    }

    function suggestedRoutes(account, amount, token, disabledChainIds) {
        return JSON.parse(walletSectionTransactions.suggestedRoutes(account, amount, token, disabledChainIds)).networks
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function setCurrentUserStatus(newStatus) {
        if (userProfileInst && userProfileInst.currentUserStatus !== newStatus) {
            mainModuleInst.setCurrentUserStatus(newStatus)
        }
    }
}
