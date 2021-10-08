import QtQuick 2.13
import "./Keycard"
import "../shared/keycard"

Item {
    property var onClosed: function () {}

    id: keycardView
    Component.onCompleted: {
        keycardModel.reset()
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
            keycardModel.onboarding()
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