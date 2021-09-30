import QtQuick 2.13
import "./Keycard"
import "../shared/keycard"

// this will be the entry point. for now it opens all keycard-related dialogs in sequence for test
Item {
    property var onClosed: function () {}
    property bool connected: false

    id: keycardView
    anchors.fill: parent
    Component.onCompleted: {
        insertCard.open()
        keycardModel.startConnection()
    }

    CreatePINModal {
        id: createPinModal
        onClosed: function () {
            keycardView.onClosed()
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
            keycardView.onClosed()
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

        }

        //TODO: support the states below

        onCardPreInit: {
            keycardView.onClosed()
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
            //status-lib currently always returns availableSlots = 0 so we end up here
            //keycardView.onClosed()
            pairingModal.open()
        }

        onCardNotKeycard: {
            keycardView.onClosed()

        }

    }
}