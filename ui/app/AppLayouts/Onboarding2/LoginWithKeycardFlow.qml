import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property int keycardState
    required property var tryToSetPinFunction
    required property int remainingAttempts

    property bool displayKeycardPromoBanner

    signal keycardPinEntered(string pin)
    signal reloadKeycardRequested
    signal keycardFactoryResetRequested
    signal createProfileWithEmptyKeycardRequested
    signal finished

    function init() {
        root.stackView.push(d.initialComponent())
    }

    QtObject {
        id: d

        function initialComponent() {
            if (root.keycardState === Onboarding.KeycardState.Empty)
                return keycardEmptyPage

            if (root.keycardState === Onboarding.KeycardState.NotEmpty)
                return keycardEnterPinPage

            return keycardIntroPage
        }

        function reload() {
            root.reloadKeycardRequested()
            root.stackView.replace(d.initialComponent(),
                                   StackView.PopTransition)
        }
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            displayPromoBanner: root.displayKeycardPromoBanner

            onReloadKeycardRequested: d.reload()
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onEmptyKeycardDetected: root.stackView.replace(keycardEmptyPage)
            onNotEmptyKeycardDetected: root.stackView.replace(keycardEnterPinPage)
        }
    }

    Component {
        id: keycardEmptyPage

        KeycardEmptyPage {
            onCreateProfileWithEmptyKeycardRequested:
                root.createProfileWithEmptyKeycardRequested()

            onReloadKeycardRequested: d.reload()
        }
    }

    Component {
        id: keycardEnterPinPage

        KeycardEnterPinPage {
            tryToSetPinFunction: root.tryToSetPinFunction
            remainingAttempts: root.remainingAttempts

            onKeycardPinEntered: {
                root.keycardPinEntered(pin)
                root.finished()
            }

            onReloadKeycardRequested: d.reload()
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        }
    }
}
