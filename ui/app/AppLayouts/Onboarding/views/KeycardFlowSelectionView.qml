import QtQuick 2.13

import shared.keycard 1.0
import "../popups"
import "../stores"

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
    Component.onCompleted: {
        insertCard.open()
        KeycardStore.startConnection()
    }

    KeycardCreatePINModal {
        id: createPinModal
        onSubmitBtnClicked: KeycardStore.init(pin)
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
        target: OnboardingStore.keycardModelInst
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
                    KeycardStore.recoverAccount();
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
