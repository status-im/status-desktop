import QtQuick 2.13
import QtQuick.Controls 2.13
import "../sounds"

Item {
    property var onClosed: function () {}
    id: existingKeyView
    anchors.fill: parent

    Component.onCompleted: {
        enterSeedPhraseModal.open()
    }

    ErrorSound {
        id: errorSound
    }

    EnterSeedPhraseModal {
        property bool wentNext: false
        id: enterSeedPhraseModal
        onConfirmSeedClick: function (mnemonic) {
            let error = onboardingModel.validateMnemonic(mnemonic)
            if (error != "") {
              errorSound.play()
              invalidSeedPhraseModal.error = error
              invalidSeedPhraseModal.open()
            } else {
              wentNext = true
              enterSeedPhraseModal.close()
              onboardingModel.importMnemonic(mnemonic)
              createPasswordModal.open()
            }
        }
        onClosed: function () {
            if (!wentNext) {
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

    InvalidSeedPhraseModal {
      id: invalidSeedPhraseModal
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
