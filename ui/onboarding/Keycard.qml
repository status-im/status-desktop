import QtQuick 2.13
import "./Keycard"
import "../shared/keycard"

// this will be the entry point. for now it opens all keycard-related dialogs in sequence for test
Item {
    property var onClosed: function () {}
    id: keycardView
    anchors.fill: parent
    Component.onCompleted: {
        createPinModal.open()
    }

    CreatePINModal {
        id: createPinModal
        onClosed: function () {
            pairingModal.open()
        }
    }

    PairingModal {
        id: pairingModal
        onClosed: function () {
            pinModal.open()
        }
    }

    PINModal {
        id: pinModal
        onClosed: function () {
            keycardView.onClosed()
        }
    }
}