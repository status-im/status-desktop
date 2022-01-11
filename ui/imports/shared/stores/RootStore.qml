pragma Singleton

import QtQuick 2.12

QtObject {
    id: root
//    property var utilsModelInst: !!utilsModel ? utilsModel :  null
//    property var chatsModelInst: !!chatsModel ?chatsModel : null
//    property var userProfileInst: !!userProfile ? userProfile : null
//    property var walletModelInst: !!walletModel ? walletModel : null
//    property var keycardModelInst: !!keycardModel ? keycardModel : null
//    property var profileModelInst: !!profileModel ? profileModel : null
    property var walletSectionInst: !!walletSection ? walletSection : null
    property var appSettings: !!localAppSettings ? localAppSettings : null
    property var accountSensitiveSettings: !!localAccountSensitiveSettings ? localAccountSensitiveSettings : null
    property real volume: !!accountSensitiveSettings ? accountSensitiveSettings.volume : 0.0
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
//    property string currentCurrency: !!walletSectionInst ? walletSectionInst.currentCurrency : ""
//    property string defaultCurrency: !!walletModelInst ? walletModelInst.balanceView.defaultCurrency : "0"
//    property string fiatValue: !!walletModelInst ? walletModelInst.balanceView.getFiatValue : "0"
//    property string cryptoValue: !!walletModelInst ? walletModelInst.balanceView.getCryptoValue : "0"
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

    function transferEth(from, to, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, uuid) {
//        return walletModelInst.transactionsView.transferEth(from, to, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, uuid);
    }

    function transferTokens(from, to, address, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, uuid) {
//        return walletModelInst.transactionsView.transferTokens(from, to, address, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, uuid);
    }

    function copyToClipboard(textToCopy) {
//        chatsModelInst.copyToClipboard(textToCopy)
    }
}
