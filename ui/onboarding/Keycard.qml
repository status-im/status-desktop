import QtQuick 2.13
import "./Keycard"
import "../shared/keycard"

Item {
    enum OnboardingFlow {
        Recover,
        Generate,
        ImportMnemonic
    }

    property var onClosed: function () {}
    property bool connected: false
    property int flow: OnboardingFlow.Recover

    id: keycardView
    anchors.fill: parent
    Component.onCompleted: {
        insertCard.open()
        keycardModel.startConnection()
    }

    CreatePINModal {
        id: createPinModal
        onClosed: function () {
            if (!createPinModal.submitted) {
                keycardView.onClosed()
            }
        }
    }

    PairingModal {
        id: pairingModal
        onClosed: function () {
            if (!pairingModal.submitted) {
                keycardView.onClosed()
            }
        }
    }

    PINModal {
        id: pinModal
        onClosed: function () {
            if (!pinModal.submitted) {
                keycardView.onClosed()
            }
        }
    }

    InsertCard {
        id: insertCard
        onCancel: function() {
            keycardView.onClosed()
        }
    }

    Connections {
        id: connection
        target: keycardModel
        ignoreUnknownSignals: true

        onCardUnpaired: {
            pairingModal.open()
        }

        onCardPaired: {
            pinModal.open()
        }

        onCardAuthenticated: {
            switch (flow) {
                case OnboardingFlow.Recover: {
                    keycardModel.recoverAccount();
                    break;
                }
                case OnboardingFlow.Generate: {
                    break;
                }
                case OnboardingFlow.ImportMnemonic: {
                    break;
                }
            }
        }

        //TODO: support the states below

        onCardPreInit: {
            createPinModal.open()
        }

        onCardFrozen: {
            keycardView.onClosed()

        }

        onCardBlocked: {
            keycardView.onClosed()
        }

        // TODO: handle these by showing an error an prompting for another card
        // later add factory reset option for the NoFreeSlots case

        onCardNoFreeSlots: {
            keycardView.onClosed()
        }

        onCardNotKeycard: {
            keycardView.onClosed()
        }

    }
}