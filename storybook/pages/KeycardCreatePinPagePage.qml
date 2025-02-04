import QtQuick 2.15

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

Item {
    id: root

    KeycardCreatePinPage {
        anchors.fill: parent
        pinSettingState: Onboarding.ProgressState.Idle
        authorizationState: Onboarding.ProgressState.Idle
        onKeycardPinCreated: (pin) => console.warn("!!! PIN CREATED:", pin)
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=595-57785&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=595-57989&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=595-58027&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=507-34789&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1053-53693&node-type=frame&m=dev
