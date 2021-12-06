import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

QtObject {
    id: root

    property CollectiblesStore collectiblesStore: CollectiblesStore { }
    property var walletModelInst: walletModel
    property var walletModelV2Inst: walletV2Model
    property var profileModelInst: profileModel
    property var chatsModelInst: chatsModel

    // This should be exposed to the UI via "walletModule", WalletModule should use
    // Accounts Service which keeps the info about that (isFirstTimeAccountLogin).
    // Then in the View of WalletModule we may have either QtProperty or
    // Q_INVOKABLE function (proc marked as slot) depends on logic/need.
    // The only need for onboardingModel here is actually to check if an account
    // has been just created or an old one.

    // property var onboardingModelInst: onboardingModel
    property int selectedAccount: 0

    function getSavedAddressErrorText(savedAddresses, error) {
        switch (error) {
            case savedAddresses.Error.CreateSavedAddressError:
                return qsTr("Error creating new saved address, please try again later.");
            case savedAddresses.Error.DeleteSavedAddressError:
                return qsTr("Error deleting saved address, please try again later.");
            case savedAddresses.Error.ReadSavedAddressesError:
                return qsTr("Error getting saved addresses, please try again later.");
            case savedAddresses.Error.UpdateSavedAddressError:
                return qsTr("Error updating saved address, please try again later.");
            default: return "";
        }
    }

    function copyText(text) {
        root.chatsModelInst.copyToClipboard(text);
    }

    function changeSelectedAccount(newIndex) {
        if (newIndex > root.walletModelV2Inst.accountsView.accounts) {
            return;
        }
        root.selectedAccount = newIndex;
        root.walletModelV2Inst.setCurrentAccountByIndex(newIndex);
    }

    function afterAddAccount() {
        changeSelectedAccount(walletModelInst.accountsView.accounts.rowCount() - 1);
    }

    function getCollectionMaxValue(traitType, value, maxValue, collectionIndex) {
        if(maxValue !== "")
            return parseInt(value) + qsTr(" of ") + maxValue;
        else
            return parseInt(value) + qsTr(" of ") +
            walletModelV2Inst.collectiblesView.collections.getCollectionTraitMaxValue(collectionIndex, traitType).toString();
    }

    property bool seedPhraseInserted: false
    property bool isSeedCountValid: false
    property bool loadingAccounts: false

    function seedPhraseNotFound(text) {
        // Read above, same story, `validateMnemonic` is method of AccountService
        // in wallet section we need to deal with it via walletModule, not anything
        // related to onboarding.

//        var seedValidationError = root.onboardingModelInst.validateMnemonic(text);
//        var regex = new RegExp('word [a-z]+ not found in the dictionary', 'i');
//        return regex.test(seedValidationError);

        return ""
    }

    function validateAddAccountPopup(text, model, keyOrSeedValid, accountNameValid) {
        if (root.isSeedCountValid && !root.seedPhraseNotFound(text)) {
            var validCount = 0;
            for (var i = 0; i < model.count; i++) {
                if (!!model.itemAtIndex(i) && model.itemAtIndex(i).nameInputValid) {
                    validCount++;
                }
            }
        }
        return (root.isSeedCountValid && !root.seedPhraseNotFound(text)) ? (validCount === model.count) :
               (keyOrSeedValid && accountNameValid);
    }

    function validateTextInput(text) {
        root.seedPhraseInserted = text.includes(" ");
        var errorMessage;
        root.isSeedCountValid = (!!text && (text.match(/(\w+)/g).length === 12));
        if (text === "") {
            errorMessage = qsTr("You need to enter a valid private key or seed phrase");
        } else {
            if (!root.seedPhraseInserted) {
                errorMessage = !Utils.isPrivateKey(text) ?
                            qsTrId("enter-a-valid-private-key-(64-characters-hexadecimal-string)") : "";
            } else {
                if (!root.isSeedCountValid) {
                    errorMessage = qsTrId("enter-a-valid-mnemonic");
                } else if (root.seedPhraseNotFound(text)) {
                    errorMessage = qsTrId("custom-seed-phrase") + '. ' + qsTrId("custom-seed-phrase-text-1");
                } else {
                    errorMessage = "";
                }
            }
        }
        return errorMessage;
    }

    function addAccount(text, model, keyOrSeedValid, accountNameInput) {
        root.loadingAccounts = true;
        if (!root.validateAddAccountPopup(text, model, keyOrSeedValid, accountNameInput.nameInputValid)) {
            Global.playErrorSound();
            root.loadingAccounts = false;
        } else {
            //TODO account color to be verified with design
            var result;
            if (root.isSeedCountValid && !root.seedPhraseNotFound(text)) {
                for (var i = 0; i < model.count; i++) {
                    //TODO add authorization process when Authorization moadl is ready
                    if (!!model.itemAtIndex(i)) {
                        result = root.walletModelInst.accountsView.addAccountsFromSeed(model.itemAtIndex(i).accountAddress, "qwqwqw", model.itemAtIndex(i).accountName, "")
                    }
                }
            } else {
                result = root.walletModelInst.accountsView.addAccountsFromPrivateKey(text, "qwqwqw", accountNameInput.text, "");
            }
            root.loadingAccounts = false;
            if (result) {
                let resultJson = JSON.parse(result);
                if (!Utils.isInvalidPasswordMessage(resultJson.error)) {
                    accountError.text = resultJson.error;
                    accountError.open();
                }
                Global.playErrorSound();
                return;
            }
        }
    }

    property MessageDialog accountError: MessageDialog {
        id: accountError
        title: qsTr("Adding the account failed")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    function deleteAccount(address) {
        walletModelInst.accountsView.deleteAccount(address);
    }

    property ListModel exampleWalletModel: ListModel {
        id: exampleWalletModel
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            isFavorite: false
        }
        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            isFavorite: false
        }
        ListElement {
            name: "Status account 2"
            address: "0x2Ef1...E0Ba"
            isFavorite: true
        }
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            isFavorite: false
        }
        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            isFavorite: false
        }
        ListElement {
            name: "Status account 2"
            address: "0x2Ef1...E0Ba"
            isFavorite: true
        }
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            isFavorite: false
        }
        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            isFavorite: false
        }
        ListElement {
            name: "Status account 2"
            address: "0x2Ef1...E0Ba"
            isFavorite: true
        }
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            isFavorite: false
        }
        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            isFavorite: false
        }
        ListElement {
            name: "Status account 2"
            address: "0x2Ef1...E0Ba"
            isFavorite: true
        }
    }
}
