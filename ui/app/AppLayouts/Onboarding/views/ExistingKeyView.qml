import QtQuick 2.13
import QtQuick.Controls 2.13

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

    EnterSeedPhraseModal {
        property bool wentNext: false
        id: enterSeedPhraseModal
        onConfirmSeedClick: function (mnemonic) {
            wentNext = true
            enterSeedPhraseModal.close()
            OnboardingStore.importMnemonic(mnemonic)
            recoverySuccessModal.open()
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
