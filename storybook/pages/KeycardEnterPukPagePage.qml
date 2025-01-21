import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Onboarding2.pages 1.0

Item {
    id: root

    readonly property string existingPuk: "111111111111"

    KeycardEnterPukPage {
        id: page
        anchors.fill: parent
        tryToSetPukFunction: (puk) => {
                                 console.warn("!!! ATTEMPTED PUK:", puk)
                                 return puk === root.existingPuk
                             }
        onKeycardPukEntered: (puk) => {
                                 console.warn("!!! CORRECT PUK:", puk)
                                 console.warn("!!! RESETTING FLOW")
                                 state = "entering"
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
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45942&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45950&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45959&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45966&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45996&node-type=frame&m=dev
