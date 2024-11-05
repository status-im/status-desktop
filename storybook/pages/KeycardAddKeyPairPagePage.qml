import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

Item {
    id: root

    KeycardAddKeyPairPage {
        id: progressPage
        anchors.fill: parent
        addKeyPairState: Onboarding.AddKeyPairState.InProgress
        timeoutInterval: 5000
        onKeypairAddTryAgainRequested: {
            console.warn("!!! onKeypairAddTryAgainRequested")
            addKeyPairState = Onboarding.AddKeyPairState.InProgress
            Backpressure.debounce(root, 2000, function() {
                console.warn("!!! SIMULATION: SUCCESS")
                addKeyPairState = Onboarding.AddKeyPairState.Success
            })()
        }
        onKeypairAddContinueRequested: console.warn("!!! onKeypairAddContinueRequested")
        onReloadKeycardRequested: console.warn("!!! onReloadKeycardRequested")
        onCreateProfilePageRequested: console.warn("!!! onCreateProfilePageRequested")
    }

    ComboBox {
        id: ctrlState
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 350
        model: ["Onboarding.AddKeyPairState.InProgress", "Onboarding.AddKeyPairState.Success", "Onboarding.AddKeyPairState.Failed"]
        onCurrentIndexChanged: progressPage.addKeyPairState = currentIndex
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1305-48023&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1305-48081&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1305-48102&node-type=frame&m=dev
