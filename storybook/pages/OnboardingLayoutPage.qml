import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import utils 1.0

import AppLayouts.Onboarding2 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores

import shared.stores 1.0 as SharedStores

// compat
import AppLayouts.Onboarding.stores 1.0 as OOBS

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: keycardMock
        property string stateType: ctrlKeycardState.currentValue

        readonly property var keycardStates: [
            // initial
            //Constants.startupState.keycardNoPCSCService,
            Constants.startupState.keycardPluginReader,
            Constants.startupState.keycardInsertKeycard,
            Constants.startupState.keycardInsertedKeycard, Constants.startupState.keycardReadingKeycard,
            // initial errors
            Constants.startupState.keycardWrongKeycard, Constants.startupState.keycardNotKeycard,
            Constants.startupState.keycardMaxPairingSlotsReached,
            Constants.startupState.keycardLocked,
            Constants.startupState.keycardNotEmpty,
            // create keycard profile
            Constants.startupState.keycardEmpty
        ]
    }

    OnboardingLayout {
        id: onboarding
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        startupStore: OOBS.StartupStore {
            readonly property var currentStartupState: QtObject {
                property string stateType: keycardMock.stateType
            }

            function getPasswordStrengthScore(password) {
                return Math.min(password.length-1, 4)
            }
            function validMnemonic(mnemonic) {
                return true
            }
            function getPin() {
                return ctrlPin.text
            }
            readonly property var startupModuleInst: QtObject {
                property int remainingAttempts: 5
            }
        }
        metricsStore: SharedStores.MetricsStore {
            readonly property var d: QtObject {
                id: d
                property bool isCentralizedMetricsEnabled
            }

            function toggleCentralizedMetrics(enabled) {
                d.isCentralizedMetricsEnabled = enabled
            }

            function addCentralizedMetricIfEnabled(eventName, eventValue = null) {}

            readonly property bool isCentralizedMetricsEnabled : d.isCentralizedMetricsEnabled
        }
        privacyStore: ProfileStores.PrivacyStore {
            readonly property var words: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]

            function getMnemonic() {
                return words.join(" ")
            }

            function mnemonicWasShown() {
                console.warn("!!! MNEMONIC SHOWN")
                logs.logEvent("mnemonicWasShown")
            }
        }

        splashScreenDurationMs: 3000

        QtObject {
            id: localAppSettings
            property bool metricsPopupSeen
        }

        onFinished: (success, primaryPath, secondaryPath) => {
            console.warn("!!! ONBOARDING FINISHED; success:", success, "; primary path:", primaryPath, "; secondary:", secondaryPath)
            logs.logEvent("onFinished", ["success", "primaryPath", "secondaryPath"], arguments)

            console.warn("!!! RESTARTING FLOW")
            restartFlow()
            ctrlKeycardState.currentIndex = 0
        }
        onKeycardFactoryResetRequested: {
            logs.logEvent("onKeycardFactoryResetRequested")
            console.warn("!!! FACTORY RESET; RESTARTING FLOW")
            restartFlow()
            ctrlKeycardState.currentIndex = 0
        }
        onKeycardReloaded: {
            logs.logEvent("onKeycardReloaded")
            console.warn("!!! RELOAD KEYCARD")
            ctrlKeycardState.currentIndex = 0
        }
    }

    Connections {
        target: Global
        function onOpenLink(link: string) {
            console.debug("Opening link in an external web browser:", link)
            Qt.openUrlExternally(link)
        }
        function onOpenLinkWithConfirmation(link: string, domain: string) {
            console.debug("Opening link in an external web browser:", link, domain)
            Qt.openUrlExternally(link)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 150
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        RowLayout {
            anchors.fill: parent
            ColumnLayout {
                Layout.fillWidth: true
                Label {
                    text: "Current page: %1".arg(onboarding.stack.currentItem ? onboarding.stack.currentItem.title : "")
                }
                Label {
                    text: `Current path: ${onboarding.primaryPath} -> ${onboarding.secondaryPath}`
                }
                Label {
                    text: "Stack depth: %1".arg(onboarding.stack.depth)
                }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                Layout.fillWidth: true
                RowLayout {
                    Button {
                        text: "Restart"
                        focusPolicy: Qt.NoFocus
                        onClicked: onboarding.restartFlow()
                    }
                    Button {
                        text: "Copy password"
                        focusPolicy: Qt.NoFocus
                        onClicked: ClipboardUtils.setText("0123456789")
                    }
                    Button {
                        text: "Copy seedphrase"
                        focusPolicy: Qt.NoFocus
                        onClicked: ClipboardUtils.setText("dog dog dog dog dog dog dog dog dog dog dog dog")
                    }
                    Button {
                        text: "Copy PIN (\"%1\")".arg(ctrlPin.text)
                        focusPolicy: Qt.NoFocus
                        enabled: ctrlPin.acceptableInput
                        onClicked: ClipboardUtils.setText(ctrlPin.text)
                    }
                }
                RowLayout {
                    Label {
                        text: "Keycard PIN:"
                    }
                    TextField {
                        id: ctrlPin
                        text: "111111"
                        inputMask: "999999"
                    }
                    Label {
                        text: "State:"
                    }
                    ComboBox {
                        Layout.preferredWidth: 250
                        id: ctrlKeycardState
                        focusPolicy: Qt.NoFocus
                        model: keycardMock.keycardStates
                    }
                }
            }
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1-25&node-type=canvas&m=dev
