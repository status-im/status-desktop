import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import "../popups"
import "../stores"
import "../shared"

Item {
    property var onClosed: function () {}

    signal showCreatePasswordView()

    id: existingKeyView
    anchors.fill: parent

    Component.onCompleted: {
        enterSeedPhraseModal.open()
    }

    Connections {
        target: onboardingModule
        onAccountImportError: {
            if (error === Constants.existingAccountError) {
                importSeedError.title = qsTr("Keys for this account already exist")
                importSeedError.text = qsTr("Keys for this account already exist and can't be added again. If you've lost your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your seed phrase")
            } else {
                importSeedError.title = qsTr("Error importing seed")
                importSeedError.text = error
            }
            importSeedError.open()
        }
        onAccountImportSuccess: {
            enterSeedPhraseModal.wentNext = true
            enterSeedPhraseModal.close()
            recoverySuccessModal.open()
        }
    }
    MessageDialog {
        id: importSeedError
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    EnterSeedPhraseModal {
        property bool wentNext: false
        id: enterSeedPhraseModal
        onConfirmSeedClick: function (mnemonic) {
            OnboardingStore.importMnemonic(mnemonic)
        }
        onClosed: function () {
            if (!wentNext) {
                existingKeyView.onClosed()
            }
        }
    }

    MnemonicRecoverySuccessModal {
        property bool wentNext: false
        id: recoverySuccessModal
        onButtonClicked: {
            recoverySuccessModal.wentNext = true
            recoverySuccessModal.close()
            showCreatePasswordView()
        }
        onClosed: function () {
            if (!recoverySuccessModal.wentNext) {
                existingKeyView.onClosed()
            }
        }
    }
}
