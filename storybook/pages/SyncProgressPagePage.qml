import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

Item {
    id: root

    SyncProgressPage {
        id: progressPage
        anchors.fill: parent
        syncState: Onboarding.SyncState.InProgress
        timeoutInterval: 5000
        onRestartSyncRequested: {
            console.warn("!!! RESTART SYNC REQUESTED")
            syncState = Onboarding.SyncState.InProgress
            Backpressure.debounce(root, 2000, function() {
                console.warn("!!! SIMULATION: SUCCESS")
                syncState = Onboarding.SyncState.Success
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
        model: ["Onboarding.SyncState.InProgress", "Onboarding.SyncState.Success", "Onboarding.SyncState.Failed"]
        onCurrentIndexChanged: progressPage.syncState = currentIndex
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=221-23716&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=224-20891&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=221-23788&node-type=frame&m=dev