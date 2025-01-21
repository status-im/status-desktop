import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Onboarding2.pages 1.0

Item {
    id: root

    readonly property string existingPuk: "111111111111"

    KeycardEnterPukPage {
        id: page
        anchors.fill: parent
        remainingAttempts: 3
        tryToSetPukFunction: (puk) => {
                                 console.warn("!!! ATTEMPTED PUK:", puk)
                                 const valid = puk === root.existingPuk
                                 if (!valid)
                                     remainingAttempts--
                                 return valid
                             }
        onKeycardPukEntered: (puk) => {
                                 console.warn("!!! CORRECT PUK:", puk)
                                 console.warn("!!! RESETTING FLOW")
                                 state = "entering"
                             }
        onKeycardFactoryResetRequested: {
            console.warn("onKeycardFactoryResetRequested")
            console.warn("!!! RESETTING FLOW")
            state = "entering"
            remainingAttempts = 3
        }
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text: "Hint: %1".arg(root.existingPuk)
    }
}

// category: Onboarding
// status: good
