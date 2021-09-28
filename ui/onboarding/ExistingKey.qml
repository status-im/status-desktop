import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

Item {
    property var onClosed: function () {}
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
            onboardingModel.importMnemonic(mnemonic)
            removeMnemonicAfterLogin = true
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
            createPasswordModal.open()
        }
        onClosed: function () {
            if (!recoverySuccessModal.wentNext) {
                existingKeyView.onClosed()
            }
        }
    }

    CreatePasswordModal {
        id: createPasswordModal
        onClosed: function () {
            existingKeyView.onClosed()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
