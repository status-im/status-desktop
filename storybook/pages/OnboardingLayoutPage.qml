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

import shared.panels 1.0
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

        readonly property var keycardStates: [ // FIXME replace with proper/separate enums for the intro/pin pages
            // initial
            Constants.startupState.keycardNoPCSCService,
            Constants.startupState.keycardPluginReader,
            Constants.startupState.keycardInsertKeycard,
            Constants.startupState.keycardInsertedKeycard,
            Constants.startupState.keycardReadingKeycard,
            Constants.startupState.keycardRecognizedKeycard,
            // initial errors
            Constants.startupState.keycardWrongKeycard,
            Constants.startupState.keycardNotKeycard,
            Constants.startupState.keycardMaxPairingSlotsReached,
            Constants.startupState.keycardLocked,
            // exit states
            Constants.startupState.keycardNotEmpty,
            Constants.startupState.keycardEmpty
        ]

        readonly property string mnemonic: "dog dog dog dog dog dog dog dog dog dog dog dog"
    }

    OnboardingLayout {
        id: onboarding
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        startupStore: OOBS.StartupStore {
            readonly property var currentStartupState: QtObject {
                property string stateType: keycardMock.stateType // Constants.startupState.keycardXXX
            }

            function getPasswordStrengthScore(password) {
                logs.logEvent("StartupStore.getPasswordStrengthScore", ["password"], arguments)
                return Math.min(password.length-1, 4)
            }
            function validMnemonic(mnemonic) {
                logs.logEvent("StartupStore.validMnemonic", ["mnemonic"], arguments)
                return mnemonic === keycardMock.mnemonic
            }
            function getPin() { // FIXME refactor to a hasPin(); there's no way to extract the PIN from the Keycard once written
                logs.logEvent("StartupStore.getPin()")
                return ctrlPin.text
            }
            function getSeedPhrase() {
                logs.logEvent("StartupStore.getSeedPhrase()")
                // FIXME needed? cf getMnemonic()
            }

            function validateLocalPairingConnectionString(connectionString) {
                logs.logEvent("StartupStore.validateLocalPairingConnectionString", ["connectionString"], arguments)
                return !Number.isNaN(parseInt(connectionString))
            }
            function setConnectionString(connectionString) {
                logs.logEvent("StartupStore.setConnectionString", ["connectionString"], arguments)
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
                logs.logEvent("PrivacyStore.getMnemonic()")
                return words.join(" ")
            }

            function mnemonicWasShown() {
                console.warn("!!! MNEMONIC SHOWN")
                logs.logEvent("PrivacyStore.mnemonicWasShown()")
            }

            function removeMnemonic() {
                console.warn("!!! REMOVE MNEMONIC")
                logs.logEvent("PrivacyStore.removeMnemonic()")
            }
        }

        splashScreenDurationMs: 3000
        biometricsAvailable: ctrlBiometrics.checked

        QtObject {
            id: localAppSettings
            property bool metricsPopupSeen
        }

        onFinished: (primaryFlow, secondaryFlow, data) => {
            console.warn("!!! ONBOARDING FINISHED; primary flow:", primaryFlow, "; secondary:", secondaryFlow, "; data:", JSON.stringify(data))
            logs.logEvent("onFinished", ["primaryFlow", "secondaryFlow", "data"], arguments)

            console.warn("!!! SIMULATION: SHOWING SPLASH")
            stack.clear()
            stack.push(splashScreen, { runningProgressAnimation: true })
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

    Component {
        id: splashScreen
        DidYouKnowSplashScreen {
            readonly property string pageClassName: "Splash"
            property bool runningProgressAnimation
            NumberAnimation on progress {
                from: 0.0
                to: 1
                duration: onboarding.splashScreenDurationMs
                running: runningProgressAnimation
                onStopped: {
                    console.warn("!!! SPLASH SCREEN DONE")
                    console.warn("!!! RESTARTING FLOW")
                    onboarding.restartFlow()
                }
            }
        }
    }

    Connections {
        target: Global
        function onOpenLink(link: string) {
            console.warn("Opening link in an external web browser:", link)
            Qt.openUrlExternally(link)
        }
        function onOpenLinkWithConfirmation(link: string, domain: string) {
            console.warn("Opening link in an external web browser:", link, domain)
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
                    text: "Current page: %1".arg(onboarding.stack.currentItem ? onboarding.stack.currentItem.pageClassName : "")
                }
                Label {
                    text: `Current flow: ${onboarding.primaryFlow} -> ${onboarding.secondaryFlow}`
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
                        onClicked: ClipboardUtils.setText(keycardMock.mnemonic)
                    }
                    Button {
                        text: "Copy PIN (\"%1\")".arg(ctrlPin.text)
                        focusPolicy: Qt.NoFocus
                        enabled: ctrlPin.acceptableInput
                        onClicked: ClipboardUtils.setText(ctrlPin.text)
                    }
                    Switch {
                        id: ctrlBiometrics
                        text: "Biometrics?"
                        checked: true
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
                        Layout.preferredWidth: 300
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
