import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property int keycardState
    required property var tryToSetPukFunction
    required property int remainingAttempts

    required property int keycardPinInfoPageDelay

    signal keycardPinCreated(string pin)
    signal reloadKeycardRequested
    signal keycardFactoryResetRequested
    signal finished(bool success)

    function init() {
        root.stackView.push(d.initialComponent())
    }

    QtObject {
        id: d

        function initialComponent() {
            if (root.keycardState === Onboarding.KeycardState.BlockedPIN)
                return keycardEnterPukPage
            if (root.keycardState === Onboarding.KeycardState.Empty || root.keycardState === Onboarding.KeycardState.NotEmpty)
                return keycardUnblockedPage
            return keycardIntroPage
        }

        function reload() {
            root.reloadKeycardRequested()
            root.stackView.replace(d.initialComponent(), StackView.PopTransition)
        }

        function finishWithFactoryReset() {
            root.keycardFactoryResetRequested()
            root.finished(false)
        }
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            unblockWithPukAvailable: root.remainingAttempts > 0
            unblockUsingSeedphraseAvailable: true
            factoryResetAvailable: !unblockWithPukAvailable
            onReloadKeycardRequested: d.reload()
            onKeycardFactoryResetRequested: d.finishWithFactoryReset()
            onEmptyKeycardDetected: root.stackView.replace(keycardUnblockedPage)
            onNotEmptyKeycardDetected: root.stackView.replace(keycardUnblockedPage)
            onUnblockWithPukRequested: root.stackView.push(keycardEnterPukPage)
        }
    }

    Component {
        id: keycardEnterPukPage

        KeycardEnterPukPage {
            tryToSetPukFunction: root.tryToSetPukFunction
            remainingAttempts: root.remainingAttempts
            onKeycardPukEntered: (puk) => root.stackView.replace(keycardCreatePinPage)
            onKeycardFactoryResetRequested: d.finishWithFactoryReset()
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinPage {
            onKeycardPinCreated: (pin) => {
                Backpressure.debounce(root, root.keycardPinInfoPageDelay, () => {
                    root.keycardPinCreated(pin)
                    root.stackView.replace(keycardUnblockedPage, {title: qsTr("Unblock successful")})
                })()
            }
        }
    }

    Component {
        id: keycardUnblockedPage

        KeycardBasePage {
            image.source: Theme.png("onboarding/keycard/success")
            title: qsTr("Your Keycard is already unblocked!")
            buttons: [
                StatusButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Continue")
                    onClicked: root.finished(true)
                }
            ]
        }
    }
}
