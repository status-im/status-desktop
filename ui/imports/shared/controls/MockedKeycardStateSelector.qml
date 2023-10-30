import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

ColumnLayout {
    id: root

    property string title
    property int selectedState: MockedKeycardStateSelector.State.EmptyKeycard

    enum State {
        NotStatusKeycard,
        EmptyKeycard,
        MaxPairingSlotsReached,
        MaxPINRetriesReached,
        MaxPUKRetriesReached,
        KeycardWithMnemonicOnly,
        KeycardWithMnemonicAndMedatada,
        CustomKeycard // should be always the last option
    }

    QtObject {
        id: d

        readonly property string kcStateNotStatusKeycard: qsTr("Not Status Keycard")
        readonly property string kcStateEmptyKeycard: qsTr("Empty Keycard")
        readonly property string kcStateMaxPairingSlotsReached: qsTr("Max Pairing Slots Reached")
        readonly property string kcStateMaxPINRetriesReached: qsTr("Max PIN Retries Reached")
        readonly property string kcStateMaxPUKRetriesReached: qsTr("Max PUK Retries Reached")
        readonly property string kcStateKeycardWithMnemonicOnly: qsTr("Keycard With Mnemonic Only")
        readonly property string kcStateKeycardWithMnemonicAndMedatada: qsTr("Keycard With Mnemonic & Metadata")
        readonly property string kcStateCustomKeycard: qsTr("Custom Keycard")
    }

    StatusBaseText {
        text: root.title
    }

    StatusButton {
        id: selectKeycardsStateButton

        text: {
            switch (root.selectedState) {
            case MockedKeycardStateSelector.State.NotStatusKeycard:
                return d.kcStateNotStatusKeycard
            case MockedKeycardStateSelector.State.EmptyKeycard:
                return d.kcStateEmptyKeycard
            case MockedKeycardStateSelector.State.MaxPairingSlotsReached:
                return d.kcStateMaxPairingSlotsReached
            case MockedKeycardStateSelector.State.MaxPINRetriesReached:
                return d.kcStateMaxPINRetriesReached
            case MockedKeycardStateSelector.State.MaxPUKRetriesReached:
                return d.kcStateMaxPUKRetriesReached
            case MockedKeycardStateSelector.State.KeycardWithMnemonicOnly:
                return d.kcStateKeycardWithMnemonicOnly
            case MockedKeycardStateSelector.State.KeycardWithMnemonicAndMedatada:
                return d.kcStateKeycardWithMnemonicAndMedatada
            case MockedKeycardStateSelector.State.CustomKeycard:
                return d.kcStateCustomKeycard
            }

            return ""
        }

        icon.name: "chevron-down"

        onClicked: {
            if (initialKeycardState.opened) {
                initialKeycardState.close()
            } else {
                initialKeycardState.popup(selectKeycardsStateButton.x, selectKeycardsStateButton.y + selectKeycardsStateButton.height + 8)
            }
        }
    }

    StatusMenu {
        id: initialKeycardState
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        StatusAction {
            text: d.kcStateNotStatusKeycard
            objectName: "notStatusKeycardAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.NotStatusKeycard
            }
        }

        StatusAction {
            text: d.kcStateEmptyKeycard
            objectName: "emptyKeycardAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.EmptyKeycard
            }
        }

        StatusAction {
            text: d.kcStateMaxPairingSlotsReached
            objectName: "maxPairingSlotsReachedAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.MaxPairingSlotsReached
            }
        }

        StatusAction {
            text: d.kcStateMaxPINRetriesReached
            objectName: "maxPINRetriesReachedAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.MaxPINRetriesReached
            }
        }

        StatusAction {
            text: d.kcStateMaxPUKRetriesReached
            objectName: "maxPUKRetriesReachedAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.MaxPUKRetriesReached
            }
        }

        StatusAction {
            text: d.kcStateKeycardWithMnemonicOnly
            objectName: "keycardWithMnemonicOnlyAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.KeycardWithMnemonicOnly
            }
        }

        StatusAction {
            text: d.kcStateKeycardWithMnemonicAndMedatada
            objectName: "keycardWithMnemonicAndMedatadaAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.KeycardWithMnemonicAndMedatada
            }
        }

        StatusAction {
            text: d.kcStateCustomKeycard
            objectName: "customKeycardAction"
            onTriggered: {
                root.selectedState = MockedKeycardStateSelector.State.CustomKeycard
            }
        }
    }
}
