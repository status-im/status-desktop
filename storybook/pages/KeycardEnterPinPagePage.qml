import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Onboarding.pages

import utils

Item {
    id: root

    readonly property string existingPin: "111111"

    KeycardEnterPinPage {
        id: page
        anchors.fill: parent

        state: KeycardEnterPinPage.State.Idle

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
                to: Constants.onboarding.defaultPinAttempts
                value: Constants.onboarding.defaultPinAttempts
            }
        }

        RowLayout {
            id: statesRow

            ButtonGroup {
                buttons: statesRow.children
            }

            Button {
                checkable: true
                checked: true
                text: "Idle"
                onClicked: page.state = KeycardEnterPinPage.State.Idle
            }
            Button {
                checkable: true
                text: "InProgress"
                onClicked: page.state = KeycardEnterPinPage.State.InProgress
            }
            Button {
                checkable: true
                text: "Success"
                onClicked: page.state = KeycardEnterPinPage.State.Success
            }
            Button {
                checkable: true
                text: "WrongPin"
                onClicked: page.state = KeycardEnterPinPage.State.WrongPin
            }
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
