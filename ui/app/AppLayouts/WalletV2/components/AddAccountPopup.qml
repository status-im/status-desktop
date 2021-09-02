import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    height: (keyOrSeedPhraseInput.input.edit.contentHeight > 56 || seedPhraseInserted) ? 517 : 498
    header.title: qsTr("Add account")
    onOpened: {
        keyOrSeedPhraseInput.input.edit.forceActiveFocus(Qt.MouseFocusReason);
    }

    property bool loading: false
    property int marginBetweenInputs: 20
    property bool seedPhraseInserted: false
    property bool isSeedCountValid: false
    signal addAccountClicked()

    function seedPhraseNotFound() {
        var seedValidationError = onboardingModel.validateMnemonic(keyOrSeedPhraseInput.text);
        var regex = new RegExp('word [a-z]+ not found in the dictionary', 'i');
        return regex.test(seedValidationError);
    }

    function validate() {
        if (popup.isSeedCountValid && !popup.seedPhraseNotFound()) {
            var validCount = 0;
            var accountsList = seedAccountDetails.activeAccountsList;
            for (var i = 0; i < accountsList.count; i++) {
                if (accountsList.itemAtIndex(i).nameInputValid) {
                    validCount++;
                }
            }
        }
        return (popup.isSeedCountValid && !popup.seedPhraseNotFound()) ? (validCount === accountsList.count) :
               (keyOrSeedPhraseInput.valid && pkeyAccountDetails.nameInputValid);
    }

    contentItem: Item {
        id: contentItem
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: parent.height

        Item {
            id: leftContent
            StatusInput {
                id: keyOrSeedPhraseInput
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: popup.marginBetweenInputs
                input.multiline: true
                input.icon.width: 15
                input.icon.height: 11
                input.icon.name: (popup.isSeedCountValid) || Utils.isPrivateKey(keyOrSeedPhraseInput.text) ? "checkmark" : ""
                input.icon.color: Theme.palette.primaryColor1
                input.leftIcon: false
                input.implicitHeight: 56
                input.placeholderText: qsTr("Enter private key or seed phrase")
                label: qsTr("Private key or seed phrase")
                validators: [
                    StatusValidator {
                        validate: function () {
                            return popup.seedPhraseInserted ? (popup.isSeedCountValid &&
                                                               !popup.seedPhraseNotFound()) : Utils.isPrivateKey(keyOrSeedPhraseInput.text);
                        }
                    }
                ]
                onTextChanged: {
                    popup.seedPhraseInserted = keyOrSeedPhraseInput.text.includes(" ");
                    if (popup.seedPhraseInserted) {
                        popup.seedPhraseInserted = true;
                        seedAccountDetails.searching = true;
                        seedAccountDetails.timer.start();
                    }

                    popup.isSeedCountValid = (!!keyOrSeedPhraseInput.text && (keyOrSeedPhraseInput.text.match(/(\w+)/g).length === 12));
                    if (text === "") {
                        errorMessage = qsTr("You need to enter a valid private key or seed phrase");
                    } else {
                        if (!popup.seedPhraseInserted) {
                            errorMessage = !Utils.isPrivateKey(keyOrSeedPhraseInput.text) ?
                                        qsTrId("enter-a-valid-private-key-(64-characters-hexadecimal-string)") : "";
                        } else {
                            if (!popup.isSeedCountValid) {
                                errorMessage = qsTrId("enter-a-valid-mnemonic");
                            } else if (popup.seedPhraseNotFound()) {
                                errorMessage = qsTrId("custom-seed-phrase") + '. ' + qsTrId("custom-seed-phrase-text-1");
                            } else {
                                errorMessage = "";
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: separator
            color: Theme.palette.statusPopupMenu.separatorColor
        }

        PKeyAccountDetails {
            id: pkeyAccountDetails
            width: parent.width
            height: parent.height/2
            anchors.top: separator.bottom
        }

        SeedAddAccountView {
            id: seedAccountDetails
            width: (parent.width/2)
            height: parent.height
            anchors.right: parent.right
        }

        states: [
            State {
                when: (popup.isSeedCountValid && !popup.seedPhraseNotFound())
                PropertyChanges {
                    target: popup
                    width: 907
                }
                PropertyChanges {
                    target: pkeyAccountDetails
                    opacity: 0.0
                }
                PropertyChanges {
                    target: leftContent
                    width: contentItem.width/2
                    height: contentItem.height
                }
                PropertyChanges {
                    target: separator
                    width: 1
                    height: contentItem.height
                }
                AnchorChanges {
                    target: separator
                    anchors.left: leftContent.right
                }
                PropertyChanges {
                    target: seedAccountDetails
                    opacity: 1.0
                }
            },
            State {
                when: !(popup.isSeedCountValid && !popup.seedPhraseNotFound())
                PropertyChanges {
                    target: popup
                    width: 574
                }
                PropertyChanges {
                    target: seedAccountDetails
                    opacity: 0.0
                }
                PropertyChanges {
                    target: leftContent
                    width: contentItem.width
                    height: 120
                }
                PropertyChanges {
                    target: pkeyAccountDetails
                    opacity: 1.0
                }
                PropertyChanges {
                    target: separator
                    width: contentItem.width
                    height: 1
                    anchors.topMargin: (2*popup.marginBetweenInputs)
                }
                AnchorChanges {
                    target: separator
                    anchors.left: contentItem.left
                    anchors.top: leftContent.bottom
                }
            }
        ]
    }

    rightButtons: [
        StatusButton {
            text: popup.loading ? qsTrId("loading") : qsTrId("add-account")
            enabled: (!popup.loading && popup.validate())

            MessageDialog {
                id: accountError
                title: qsTr("Adding the account failed")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                popup.loading = true;
                if (!popup.validate()) {
                    errorSound.play();
                    popup.loading = false;
                } else {
                    //TODO account color to be verified with design
                    var result;
                    if (popup.isSeedCountValid && !popup.seedPhraseNotFound()) {
                        var accountsList = seedAccountDetails.activeAccountsList;
                        for (var i = 0; i < accountsList.count; i++) {
                            //TODO remove password requirement
                            if (!!accountsList.itemAtIndex(i)) {
                                result = walletModel.accountsView.addAccountsFromSeed(accountsList.itemAtIndex(i).accountAddress, "", accountsList.itemAtIndex(i).accountName, "")
                            }
                        }
                    } else {
                        result = walletModel.accountsView.addAccountsFromPrivateKey(keyOrSeedPhraseInput.text, "", pkeyAccountDetails.accountName, "");
                    }
                    popup.loading = false;
                    if (result) {
                        let resultJson = JSON.parse(result);
                        if (!Utils.isInvalidPasswordMessage(resultJson.error)) {
                            accountError.text = resultJson.error;
                            accountError.open();
                        }
                        errorSound.play();
                        return;
                    }
                    popup.addAccountClicked();
                    popup.close();
                }
            }
        }
    ]
}
