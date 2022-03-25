pragma Singleton

import QtQuick 2.12

QtObject {
    id: root
//    property var utilsModelInst: !!utilsModel ? utilsModel :  null
//    property var chatsModelInst: !!chatsModel ?chatsModel : null
//    property var walletModelInst: !!walletModel ? walletModel : null
//    property var keycardModelInst: !!keycardModel ? keycardModel : null
//    property var profileModelInst: !!profileModel ? profileModel : null

    property var profileSectionModuleInst: profileSectionModule
    property var privacyModule: profileSectionModuleInst.privacyModule
    property var onboardingModuleInst: onboardingModule
    property var userProfileInst: !!userProfile ? userProfile : null
    property var walletSectionInst: !!walletSection ? walletSection : null
    property var appSettings: !!localAppSettings ? localAppSettings : null
    property var accountSensitiveSettings: !!localAccountSensitiveSettings ? localAccountSensitiveSettings : null
    property real volume: !!accountSensitiveSettings ? accountSensitiveSettings.volume * 0.1 : 0.2
    property bool isWalletEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.isWalletEnabled : false
    property bool notificationSoundsEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.notificationSoundsEnabled : false
    property bool neverAskAboutUnfurlingAgain: !!accountSensitiveSettings ? accountSensitiveSettings.neverAskAboutUnfurlingAgain : false
    property bool isGifWidgetEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.isGifWidgetEnabled : false
    property bool isTenorWarningAccepted: !!accountSensitiveSettings ? accountSensitiveSettings.isTenorWarningAccepted : false
    property bool displayChatImages: !!accountSensitiveSettings ? accountSensitiveSettings.displayChatImages : false

    property string locale: !!appSettings ? appSettings.locale : ""
//    property string signingPhrase: !!walletModelInst ? walletModelInst.utilsView.signingPhrase : ""
//    property string gasPrice: !!walletModelInst ? walletModelInst.gasView.gasPrice : "0"
//    property string gasEthValue: !!walletModelInst ? walletModelInst.gasView.getGasEthValue : "0"
    property string currentCurrency: walletSection.currentCurrency
//    property string defaultCurrency: !!walletModelInst ? walletModelInst.balanceView.defaultCurrency : "0"
//    property string fiatValue: !!walletModelInst ? walletModelInst.balanceView.getFiatValue : "0"
//    property string cryptoValue: !!walletModelInst ? walletModelInst.balanceView.getCryptoValue : "0"

    property var history: walletSectionTransactions
    property var historyTransactions: walletSectionTransactions.model
    property bool isNonArchivalNode:  history.isNonArchivalNode

    property var walletTokensModule: walletSectionAllTokens
    property var tokens: walletSectionAllTokens.all

    readonly property var formationChars: (["*", "`", "~"])
    function getSelectedTextWithFormationChars(messageInputField) {
        let i = 1
        let text = ""
        while (true) {
            if (messageInputField.selectionStart - i < 0 && messageInputField.selectionEnd + i > messageInputField.length) {
                break
            }

            text = messageInputField.getText(messageInputField.selectionStart - i, messageInputField.selectionEnd + i)

            if (!formationChars.includes(text.charAt(0)) ||
                    !formationChars.includes(text.charAt(text.length - 1))) {
                break
            }
            i++
        }
        return text
    }

    function setNeverAskAboutUnfurlingAgain(value) {
        localAccountSensitiveSettings.neverAskAboutUnfurlingAgain = value;
    }

    function enableWallet() {
        localAccountSensitiveSettings.isWalletEnabled = true;
    }

    function setIsTenorWarningAccepted(value) {
        localAccountSensitiveSettings.isTenorWarningAccepted = value;
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    property var gifColumnA: chatSectionChatContentInputArea.gifColumnA
    property var gifColumnB: chatSectionChatContentInputArea.gifColumnB
    property var gifColumnC: chatSectionChatContentInputArea.gifColumnC

    function searchGifs(query) {
        chatSectionChatContentInputArea.searchGifs(query)
    }

    function getTrendingsGifs() {
        chatSectionChatContentInputArea.getTrendingsGifs()
    }

    function getRecentsGifs() {
        chatSectionChatContentInputArea.getRecentsGifs()
    }

    function getFavoritesGifs() {
        return chatSectionChatContentInputArea.getFavoritesGifs()
    }

    function isFavorite(id) {
        return chatSectionChatContentInputArea.isFavorite(id)
    }

    function toggleFavoriteGif(id, reload) {
        chatSectionChatContentInputArea.toggleFavoriteGif(id, reload)
    }

    function addToRecentsGif(id) {
        chatSectionChatContentInputArea.addToRecentsGif(id)
    }

    function getPasswordStrengthScore(password, onboarding = false) {
        if (onboarding) {
            let userName = root.onboardingModuleInst.importedAccountAlias;
            return root.onboardingModuleInst.getPasswordStrengthScore(password, userName);
        } else {
            return root.privacyModule.getPasswordStrengthScore(password);
        }
    }

    function isFetchingHistory(address) {
        return history.isFetchingHistory(address)
    }

    function loadTransactionsForAccount(address, pageSize) {
        history.loadTransactionsForAccount(address, historyTransactions.getLastTxBlockNumber(), pageSize, true)
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }
}
