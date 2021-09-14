import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../views"
import "../panels"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root
    height: (keyOrSeedPhraseInput.input.edit.contentHeight > 56 || root.store.seedPhraseInserted) ? 517 : 498
    header.title: qsTr("Add account")

    property int marginBetweenInputs: 20
    property var store
    signal addAccountClicked()

    onOpened: {
        keyOrSeedPhraseInput.input.edit.forceActiveFocus(Qt.MouseFocusReason);
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
            width: parent.width
            height: parent.height/2
            anchors.top: parent.top
            anchors.topMargin: root.marginBetweenInputs
            StatusInput {
                id: keyOrSeedPhraseInput
                anchors.fill: parent
                input.multiline: true
                input.icon.width: 15
                input.icon.height: 11
                input.icon.name: (root.store.isSeedCountValid) || Utils.isPrivateKey(keyOrSeedPhraseInput.text) ? "checkmark" : ""
                input.icon.color: Theme.palette.primaryColor1
                input.leftIcon: false
                input.implicitHeight: 56
                input.placeholderText: qsTr("Enter private key or seed phrase")
                label: qsTr("Private key or seed phrase")
                validators: [
                    StatusValidator {
                        validate: function (t) {
                            errorMessage = root.store.validateTextInput(t);
                            return ((t !== "") && ((root.store.isSeedCountValid && !root.store.seedPhraseNotFound(t))
                                    || Utils.isPrivateKey(t))) ? true : { actual: t }
                        }
                    }
                ]
                onTextChanged: {
                    if (root.store.seedPhraseInserted) {
                        root.store.seedPhraseInserted = true;
                        seedAccountDetails.searching = true;
                        seedAccountDetails.timer.start();
                    }
                }
            }
        }

        Rectangle {
            id: separator
            color: Theme.palette.statusPopupMenu.separatorColor
        }

        PKeyAccountDetailsPanel {
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
            store: root.store
        }

        states: [
            State {
                when: (root.store.isSeedCountValid && !root.store.seedPhraseNotFound(keyOrSeedPhraseInput.text))
                PropertyChanges {
                    target: root
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
                when: !(root.store.isSeedCountValid && !root.store.seedPhraseNotFound(keyOrSeedPhraseInput.text))
                PropertyChanges {
                    target: root
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
                    anchors.topMargin: (2*root.marginBetweenInputs)
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
            text: root.store.loadingAccounts ? qsTrId("loading") : qsTrId("add-account")
            enabled: (!root.loadingAccounts && root.store.validateAddAccountPopup(keyOrSeedPhraseInput.text, seedAccountDetails.activeAccountsList,
                                                                                  keyOrSeedPhraseInput.valid, pkeyAccountDetails.nameInputValid))

            onClicked : {
                root.store.addAccount(keyOrSeedPhraseInput.text, seedAccountDetails.activeAccountsList,
                                      keyOrSeedPhraseInput.valid, pkeyAccountDetails);
                root.addAccountClicked();
                root.close();
            }
        }
    ]
}
