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
    width: 574
    height: (keyOrSeedPhraseInput.height > 100) ? 517 : 498
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
        return (keyOrSeedPhraseInput.valid && accountNameInput.valid);
    }

    contentItem: Item {
        id: contentItem
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: parent.height

        Item {
            id: seedOrPKInputContainer
            width: parent.width
            height: 120 + ((keyOrSeedPhraseInput.height > 100) ? 30 : 0)

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

        Separator {
            id: separator
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: seedOrPKInputContainer.bottom
            anchors.topMargin: (2*popup.marginBetweenInputs)
        }

        Row {
            id: accountNameInputRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: separator.bottom
            anchors.topMargin: popup.marginBetweenInputs
            height: (parent.height/2)
            StatusInput {
                id: accountNameInput
                implicitWidth: (parent.width - emojiDropDown.width)
                input.implicitHeight: 56
                input.placeholderText: qsTrId("enter-an-account-name...")
                label: qsTrId("account-name")
                validators: [StatusMinLengthValidator { minLength: 1 }]
                onTextChanged: {
                    errorMessage = (accountNameInput.text === "") ?
                                qsTrId("you-need-to-enter-an-account-name") : ""
                }
            }
            Item {
                id: emojiDropDown
                //emoji placeholder
                width: 80
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: 11
                StyledText {
                    id: inputLabel
                    text: "Emoji"
                    font.weight: Font.Medium
                    font.pixelSize: 13
                    color: Style.current.textColor
                }
                Rectangle {
                    width: parent.width
                    height: 56
                    anchors.top: inputLabel.bottom
                    anchors.topMargin: 7
                    radius: 10
                    color: "pink"
                    opacity: 0.6
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: popup.loading ? qsTrId("loading") : qsTrId("add-account")
            enabled: !popup.loading && (accountNameInput.text !== "")
                     && (keyOrSeedPhraseInput.correctWordCount || (keyOrSeedPhraseInput.text !== ""))

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
                    const result = popup.seedPhraseInserted ?
                                     walletModel.accountsView.addAccountsFromSeed(keyOrSeedPhraseInput.text, "", accountNameInput.text, "") :
                                     walletModel.accountsView.addAccountsFromPrivateKey(keyOrSeedPhraseInput.text, "", accountNameInput.text, "");
                    popup.loading = false;
                    if (result) {
                        let resultJson = JSON.parse(result);
                        accountError.text = resultJson.error;
                        accountError.open();
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
