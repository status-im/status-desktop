import QtQuick
import QtQuick.Controls

import AppLayouts.Onboarding.pages

import utils

Item {
    id: root

    readonly property string existingPuk: "111111111111"

    KeycardEnterPukPage {
        id: page
        anchors.fill: parent
        remainingAttempts: Constants.onboarding.defaultPukAttempts
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
            remainingAttempts = Constants.onboarding.defaultPukAttempts
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
