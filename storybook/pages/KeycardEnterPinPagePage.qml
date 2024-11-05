import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Onboarding2.pages 1.0

Item {
    id: root

    readonly property string existingPin: "111111"

    KeycardEnterPinPage {
        id: page
        anchors.fill: parent
        tryToSetPinFunction: (pin) => {
                                 const valid = pin === root.existingPin
                                 if (!valid)
                                     remainingAttempts--
                                 return valid
                             }
        remainingAttempts: 3
        onKeycardPinEntered: (pin) => {
                                 console.warn("!!! PIN:", pin)
                                 console.warn("!!! RESETTING FLOW")
                                 state = "entering"
                             }
        onReloadKeycardRequested: {
            console.warn("!!! RELOAD KEYCARD")
            remainingAttempts--
            state = "entering"
        }
        onKeycardFactoryResetRequested: {
            console.warn("!!! FACTORY RESET KEYCARD")
            remainingAttempts = 3
            state = "entering"
        }
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text: "Hint: %1".arg(root.existingPin)
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45942&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45950&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45959&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45966&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45996&node-type=frame&m=dev
