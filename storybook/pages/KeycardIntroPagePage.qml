import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

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
            onReloadKeycardRequested: console.warn("!!! RELOAD REQUESTED")
            onOpenLink: Qt.openUrlExternally(link)
            onOpenLinkWithConfirmation: Qt.openUrlExternally(link)
            onKeycardFactoryResetRequested: console.warn("!!! FACTORY RESET")
            onUnblockWithSeedphraseRequested: console.warn("!!! UNBLOCK WITH SEEDPHRASE")
            onUnblockWithPukRequested: console.warn("!!! UNBLOCK WITH PUK")
        }
    }

    Component {
        id: emptyPage
        KeycardEmptyPage {
            onCreateProfileWithEmptyKeycardRequested: console.warn("!!! CREATE NEW PROFILE")
            onReloadKeycardRequested: console.warn("!!! RELOAD REQUESTED")
        }
    }

    Component {
        id: notEmptyPage
        KeycardNotEmptyPage {
            onReloadKeycardRequested: console.warn("!!! RELOAD REQUESTED")
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
