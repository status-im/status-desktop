import QtQuick
import QtQuick.Controls

import StatusQ.Core.Backpressure

import AppLayouts.Onboarding.pages
import AppLayouts.Onboarding.enums

Item {
    id: root

    SyncProgressPage {
        id: progressPage
        anchors.fill: parent
        syncState: ctrlState.currentValue
        onRestartSyncRequested: {
            console.warn("!!! RESTART SYNC REQUESTED")
            ctrlState.currentIndex = ctrlState.indexOfValue(Onboarding.ProgressState.InProgress)
            Backpressure.debounce(root, 2000, function() {
                console.warn("!!! SIMULATION: SUCCESS")
                ctrlState.currentIndex = ctrlState.indexOfValue(Onboarding.ProgressState.Success)
            })()
        }
        onLoginToAppRequested: console.warn("!!! LOGIN TO APP REQUESTED")
        onLoginWithSeedphraseRequested: console.warn("!!! LOGIN WITH SEEDPHRASE REQUESTED")
    }

    ComboBox {
        id: ctrlState
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 300
        textRole: "name"
        valueRole: "value"
        model: Onboarding.getModelFromEnum("LocalPairingState")
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=221-23716&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=224-20891&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=221-23788&node-type=frame&m=dev
