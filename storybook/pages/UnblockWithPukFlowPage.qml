import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import utils 1.0

import AppLayouts.Onboarding2 1.0
import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        OnboardingStackView {
            id: stackView
            anchors.fill: parent
            Component.onCompleted: flow.init()
        }

        // needs to be on top of the stack
        // we're here only to provide the Back button feature
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.BackButton
            cursorShape: undefined // don't override the cursor coming from the stack
            enabled: stackView.depth > 1 && !stackView.busy
            onClicked: stackView.pop()
        }

        StatusBackButton {
            width: 44
            height: 44
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Theme.padding

            opacity: stackView.depth > 1 && !stackView.busy && stackView.backAvailable ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }

            onClicked: stackView.pop()
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: stackView.currentItem instanceof KeycardEnterPukPage

            text: "Copy valid PUK (\"%1\")".arg(mockDriver.puk)
            focusPolicy: Qt.NoFocus
            onClicked: {
                ClipboardUtils.setText(mockDriver.puk)
            }
        }
    }

    UnblockWithPukFlow {
        id: flow
        stackView: stackView
        keycardState: mockDriver.keycardState
        pinSettingState: pinSettingStateSelector.value
        tryToSetPukFunction: mockDriver.setPuk
        remainingAttempts: mockDriver.keycardRemainingPukAttempts
        onSetPinRequested: (pin) => {
            logs.logEvent("setPinRequested", ["pin"], arguments)
            console.warn("!!! SET PIN REQUESTED:", pin)
        }
        onKeycardFactoryResetRequested: {
            logs.logEvent("keycardFactoryResetRequested", ["pin"], arguments)
            console.warn("!!! FACTORY RESET REQUESTED")
        }
        onFinished: (success) => {
            console.warn("!!! UNLOCK WITH PUK FINISHED:", success)
            logs.logEvent("finished", ["success"], arguments)
            console.warn("!!! RESTARTING FLOW")

            stackView.clear()
            mockDriver.reset()
            flow.init()
        }
    }

    QtObject {
        id: mockDriver

        function reset() {
            keycardState = Onboarding.KeycardState.NoPCSCService
            keycardRemainingPukAttempts = Constants.onboarding.defaultPukAttempts
        }

        property int keycardState: Onboarding.KeycardState.NoPCSCService
        property int keycardRemainingPukAttempts: Constants.onboarding.defaultPukAttempts

        function setPuk(puk) { // -> bool
            logs.logEvent("setPuk", ["puk"], arguments)
            console.warn("!!! SET PUK:", puk)
            const valid = puk === mockDriver.puk
            if (!valid)
                keycardRemainingPukAttempts--
            if (keycardRemainingPukAttempts <= 0) { // SIMULATION: "block" the keycard
                keycardState = Onboarding.KeycardState.BlockedPUK
                keycardRemainingPukAttempts = 0
            }
            return valid
        }

        readonly property string puk: "111111111111"
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 200
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            spacing: 10

            TextField {
                Layout.fillWidth: true

                text: {
                    const stack = stackView
                    let content = `Stack (${stack.depth}):`

                    for (let i = 0; i < stack.depth; i++)
                        content += " -> " + InspectionUtils.baseName(
                                    stack.get(i, StackView.ForceLoad))

                    return content
                }

                background: null
                readOnly: true
                selectByMouse: true
                wrapMode: Text.Wrap
            }

            RowLayout {
                Label {
                    text: "Keycard state:"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 2

                    ButtonGroup {
                        id: keycardStateButtonGroup
                    }

                    Repeater {
                        model: Onboarding.getModelFromEnum("KeycardState")

                        RoundButton {
                            text: modelData.name
                            checkable: true
                            checked: flow.keycardState === modelData.value

                            ButtonGroup.group: keycardStateButtonGroup

                            onClicked: mockDriver.keycardState = modelData.value
                        }
                    }
                }
            }

            ProgressSelector {
                id: pinSettingStateSelector

                label: "Pin setting progress"
            }
        }
    }
}

// category: Onboarding
// status: good
