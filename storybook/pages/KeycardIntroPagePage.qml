import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Onboarding.pages
import AppLayouts.Onboarding.enums

Item {
    id: root

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            switch (ctrlKeycardState.currentValue) {
            case Onboarding.KeycardState.Empty: return emptyPage
            case Onboarding.KeycardState.NotEmpty: return notEmptyPage
            default: introPage
            }
        }
    }

    Component {
        id: introPage
        KeycardIntroPage {
            keycardState: ctrlKeycardState.currentValue
            unblockWithPukAvailable: ctrlUnblockWithPUK.checked
            unblockUsingSeedphraseAvailable: ctrlUnblockWithSeedphrase.checked
            factoryResetAvailable: ctrlFactoryReset.checked
            displayPromoBanner: ctrlDisplayPromo.checked
            onEmptyKeycardDetected: console.warn("!!! EMPTY DETECTED")
            onNotEmptyKeycardDetected: console.warn("!!! NOT EMPTY DETECTED")
            onRequestOpenLink: Qt.openUrlExternally(link)
            onKeycardFactoryResetRequested: console.warn("!!! FACTORY RESET")
            onUnblockWithSeedphraseRequested: console.warn("!!! UNBLOCK WITH SEEDPHRASE")
            onUnblockWithPukRequested: console.warn("!!! UNBLOCK WITH PUK")
        }
    }

    Component {
        id: emptyPage
        KeycardEmptyPage {
            onCreateProfileWithEmptyKeycardRequested: console.warn("!!! CREATE NEW PROFILE")
        }
    }

    Component {
        id: notEmptyPage
        KeycardNotEmptyPage {
            onLoginWithThisKeycardRequested: console.warn("!!! LOGIN REQUESTED")
            onKeycardFactoryResetRequested: console.warn("!!! FACTORY RESET")
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        CheckBox {
            id: ctrlUnblockWithPUK
            text: "Unblock with PUK available"
            checked: true
        }

        CheckBox {
            id: ctrlUnblockWithSeedphrase
            text: "Unblock with seedphrase available"
            checked: true
        }

        CheckBox {
            id: ctrlFactoryReset
            text: "Factory reset available"
            checked: true
        }

        Item { Layout.fillWidth: true }

        CheckBox {
            id: ctrlDisplayPromo
            text: "Promo banner"
            checked: true
            visible: ctrlKeycardState.currentValue === Onboarding.KeycardState.PluginReader
        }
        ToolButton {
            text: "<"
            onClicked: ctrlKeycardState.decrementCurrentIndex()
        }
        ComboBox {
            id: ctrlKeycardState

            focusPolicy: Qt.NoFocus
            Layout.preferredWidth: 250
            textRole: "name"
            valueRole: "value"
            model: Onboarding.getModelFromEnum("KeycardState")
        }
        ToolButton {
            text: ">"
            onClicked: ctrlKeycardState.incrementCurrentIndex()
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=507-34558&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=507-34583&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=507-34608&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=595-57486&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=595-57709&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=972-44743&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=972-44633&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=972-44611&node-type=frame&m=dev
