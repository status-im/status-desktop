import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

Item {
    id: root

    readonly property string existingPin: "111111"

    KeycardEnterPinPage {
        id: page
        anchors.fill: parent

        authorizationState: authorizationProgressSelector.value
        remainingAttempts: remainingAttemptsSpinBox.value

        unblockWithPukAvailable: ctrlUnblockWithPUK.checked

        onAuthorizationRequested: (pin) => {
            console.log("authorization requested:", pin)
        }

        onUnblockWithSeedphraseRequested: console.log("unblock with seed phrase requested")
        onUnblockWithPukRequested: console.log("unblock with puk requested")
        onKeycardFactoryResetRequested: console.log("factory reset requested")
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 15

        spacing: 15

        Label {
            text: "Hint: %1".arg(root.existingPin)
        }

        CheckBox {
            id: ctrlUnblockWithPUK
            text: "Unblock with PUK available"
            checked: true
        }

        RowLayout {
            Label {
                text: "Remaining attempts: "
            }

            SpinBox {
                id: remainingAttemptsSpinBox

                from: 0
                to: 3
                value: 3
            }
        }

        ProgressSelector {
            id: authorizationProgressSelector

            label: "Authorization progress"
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45942&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45950&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45959&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45966&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1281-45996&node-type=frame&m=dev
