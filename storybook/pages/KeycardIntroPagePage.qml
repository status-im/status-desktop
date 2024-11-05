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
            displayPromoBanner: ctrlDisplayPromo.checked
            onEmptyKeycardDetected: console.warn("!!! EMPTY DETECTED")
            onNotEmptyKeycardDetected: console.warn("!!! NOT EMPTY DETECTED")
            onReloadKeycardRequested: console.warn("!!! RELOAD REQUESTED")
            onOpenLink: Qt.openUrlExternally(link)
            onOpenLinkWithConfirmation: Qt.openUrlExternally(link)
            onKeycardFactoryResetRequested: console.warn("!!! FACTORY RESET")
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
            id: ctrlDisplayPromo
            text: "Promo banner"
            checked: true
            visible: ctrlKeycardState.currentValue === Onboarding.KeycardState.InsertKeycard
        }
        ToolButton {
            text: "<"
            onClicked: ctrlKeycardState.decrementCurrentIndex()
        }
        ComboBox {
            id: ctrlKeycardState

            focusPolicy: Qt.NoFocus
            Layout.preferredWidth: 250
            textRole: "text"
            valueRole: "value"
            model: [
                { value: Onboarding.KeycardState.NoPCSCService, text: "NoPCSCService" },
                { value: Onboarding.KeycardState.PluginReader, text: "PluginReader" },
                { value: Onboarding.KeycardState.InsertKeycard, text: "InsertKeycard" },
                { value: Onboarding.KeycardState.ReadingKeycard, text: "ReadingKeycard" },
                { value: Onboarding.KeycardState.WrongKeycard, text: "WrongKeycard" },
                { value: Onboarding.KeycardState.NotKeycard, text: "NotKeycard" },
                { value: Onboarding.KeycardState.MaxPairingSlotsReached, text: "MaxPairingSlotsReached" },
                { value: Onboarding.KeycardState.Locked, text: "Locked" },
                { value: Onboarding.KeycardState.NotEmpty, text: "NotEmpty" },
                { value: Onboarding.KeycardState.Empty, text: "Empty" }
            ]
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
