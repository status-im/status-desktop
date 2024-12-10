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
import AppLayouts.Onboarding2.stores 1.0
import AppLayouts.Onboarding.enums 1.0

import shared.panels 1.0
import shared.stores 1.0 as SharedStores

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: mockDriver
        readonly property string mnemonic: "dog dog dog dog dog dog dog dog dog dog dog dog"
        readonly property var seedWords: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]

        // TODO simulation
        function restart() {
            // add keypair state
            // sync state
        }
    }

    OnboardingLayout {
        id: onboarding
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        onboardingStore: OnboardingStore {
            readonly property int keycardState: ctrlKeycardState.currentValue // enum Onboarding.KeycardState
            property int keycardRemainingPinAttempts: 5

            function setPin(pin: string) { // -> bool
                logs.logEvent("OnboardingStore.setPin", ["pin"], arguments)
                const valid = pin === ctrlPin.text
                if (!valid)
                    keycardRemainingPinAttempts--
                return valid
            }

            readonly property int addKeyPairState: Onboarding.AddKeyPairState.InProgress // enum Onboarding.AddKeyPairState
            function startKeypairTransfer() { // -> void
                logs.logEvent("OnboardingStore.startKeypairTransfer")
            }

            // password
            function getPasswordStrengthScore(password: string) { // -> int
                logs.logEvent("OnboardingStore.getPasswordStrengthScore", ["password"], arguments)
                return Math.min(password.length-1, 4)
            }

            // seedphrase/mnemonic
            function validMnemonic(mnemonic: string) { // -> bool
                logs.logEvent("OnboardingStore.validMnemonic", ["mnemonic"], arguments)
                return mnemonic === mockDriver.mnemonic
            }
            function getMnemonic() { // -> string
                logs.logEvent("OnboardingStore.getMnemonic()")
                return mockDriver.seedWords.join(" ")
            }
            function mnemonicWasShown() { // -> void
                console.warn("!!! MNEMONIC SHOWN")
                logs.logEvent("OnboardingStore.mnemonicWasShown()")
            }
            function removeMnemonic() { // -> void
                console.warn("!!! REMOVE MNEMONIC")
                logs.logEvent("OnboardingStore.removeMnemonic()")
            }

            readonly property int syncState: Onboarding.SyncState.InProgress // enum Onboarding.SyncState
            function validateLocalPairingConnectionString(connectionString: string) { // -> bool
                logs.logEvent("OnboardingStore.validateLocalPairingConnectionString", ["connectionString"], arguments)
                return !Number.isNaN(parseInt(connectionString))
            }
            function setConnectionString(connectionString: string) { // -> void
                logs.logEvent("OnboardingStore.setConnectionString", ["connectionString"], arguments)
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
                        onClicked: ClipboardUtils.setText(mockDriver.mnemonic)
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
                }
            }
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1-25&node-type=canvas&m=dev
