import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2 1.0
import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding2.stores 1.0

import shared.panels 1.0
import shared.stores 1.0 as SharedStores
import utils 1.0

import Storybook 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: mockDriver

        readonly property string mnemonic: "dog dog dog dog dog dog dog dog dog dog dog dog"
        readonly property var seedWords: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]
        readonly property string pin: "111111"

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
            id: store

            property int keycardState: Onboarding.KeycardState.NoPCSCService
            property int addKeyPairState: Onboarding.AddKeyPairState.InProgress
            property int syncState: Onboarding.SyncState.InProgress

            property int keycardRemainingPinAttempts: 5

            function setPin(pin: string) { // -> bool
                logs.logEvent("OnboardingStore.setPin", ["pin"], arguments)
                const valid = pin === mockDriver.pin
                if (!valid)
                    keycardRemainingPinAttempts--
                return valid
            }

            function startKeypairTransfer() { // -> void
                logs.logEvent("OnboardingStore.startKeypairTransfer")
                addKeyPairState = Onboarding.AddKeyPairState.InProgress
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
                logs.logEvent("OnboardingStore.mnemonicWasShown()")
            }

            function removeMnemonic() { // -> void
                logs.logEvent("OnboardingStore.removeMnemonic()")
            }

            function validateLocalPairingConnectionString(connectionString: string) { // -> bool
                logs.logEvent("OnboardingStore.validateLocalPairingConnectionString", ["connectionString"], arguments)
                return !Number.isNaN(parseInt(connectionString))
            }

            function inputConnectionStringForBootstrapping(connectionString: string) { // -> void
                logs.logEvent("OnboardingStore.inputConnectionStringForBootstrapping", ["connectionString"], arguments)
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

        onFinished: (flow, data) => {
            console.warn("!!! ONBOARDING FINISHED; flow:", flow, "; data:", JSON.stringify(data))
            logs.logEvent("onFinished", ["flow", "data"], arguments)

            console.warn("!!! SIMULATION: SHOWING SPLASH")
            stack.clear()
            stack.push(splashScreen, { runningProgressAnimation: true })

            flow.currentKeycardState = Onboarding.KeycardState.NoPCSCService
        }
        onKeycardFactoryResetRequested: {
            logs.logEvent("onKeycardFactoryResetRequested")
            console.warn("!!! FACTORY RESET; RESTARTING FLOW")
            restartFlow()
            flow.currentKeycardState = Onboarding.KeycardState.NoPCSCService
        }
        onKeycardReloaded: {
            logs.logEvent("onKeycardReloaded")
            console.warn("!!! RELOAD KEYCARD")
            flow.currentKeycardState = Onboarding.KeycardState.NoPCSCService
        }

        Button {
            text: "Paste password"
            focusPolicy: Qt.NoFocus

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.stack.currentItem instanceof CreatePasswordPage

            onClicked: {
                const password = "somepassword"
                const currentItem = onboarding.stack.currentItem

                const input1 = StorybookUtils.findChild(
                                 currentItem,
                                 "passwordViewNewPassword")
                const input2 = StorybookUtils.findChild(
                                 currentItem,
                                 "passwordViewNewPasswordConfirm")

                if (!input1 || !input2)
                    return

                input1.text = password
                input2.text = password
            }
        }

        Button {
            text: "Paste seed phrase"
            focusPolicy: Qt.NoFocus

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.stack.currentItem instanceof SeedphrasePage

            onClicked: {
                for (let i = 1;; i++) {
                    const input = StorybookUtils.findChild(
                                    onboarding.stack.currentItem,
                                    `enterSeedPhraseInputField${i}`)

                    if (input === null)
                        break

                    input.text = "dog"
                }
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.stack.currentItem instanceof KeycardEnterPinPage ||
                     onboarding.stack.currentItem instanceof KeycardCreatePinPage

            text: "Copy valid PIN (\"%1\")".arg(mockDriver.pin)
            focusPolicy: Qt.NoFocus
            onClicked: ClipboardUtils.setText(mockDriver.pin)
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.stack.currentItem instanceof BackupSeedphraseVerify

            text: "Paste seed phrase verification"
            focusPolicy: Qt.NoFocus
            onClicked: {
                for (let i = 0;; i++) {
                    const input = StorybookUtils.findChild(
                                    onboarding.stack.currentItem,
                                    `seedInput_${i}`)

                    if (input === null)
                        break

                    const index = input.seedWordIndex
                    input.text = mockDriver.seedWords[index]
                }
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.stack.currentItem instanceof BackupSeedphraseAcks

            text: "Paste seed phrase verification"
            focusPolicy: Qt.NoFocus
            onClicked: {
                for (let i = 1;; i++) {
                    const checkBox = StorybookUtils.findChild(
                                       onboarding.stack.currentItem,
                                       `ack${i}`)

                    if (checkBox === null)
                        break

                    checkBox.checked = true
                }
            }
        }
    }

    Component {
        id: splashScreen

        DidYouKnowSplashScreen {
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

        SplitView.minimumHeight: 250
        SplitView.preferredHeight: 250

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            spacing: 10

            Label {
                Layout.fillWidth: true

                text: {
                    const stack = onboarding.stack
                    let content = `Stack (${stack.depth}):`

                    for (let i = 0; i < stack.depth; i++)
                        content += " " + InspectionUtils.baseName(
                                    stack.get(i, StackView.ForceLoad))

                    return content
                }

                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Restart"
                    focusPolicy: Qt.NoFocus
                    onClicked: onboarding.restartFlow()
                }

                Switch {
                    id: ctrlBiometrics
                    text: "Biometrics available"
                    checked: true
                }
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

                        RoundButton {
                            text: modelData.text
                            checkable: true
                            checked: store.keycardState === modelData.value

                            ButtonGroup.group: keycardStateButtonGroup

                            onClicked: store.keycardState = modelData.value
                        }
                    }
                }
            }

            RowLayout {
                Label {
                    text: "Add key pair state:"
                }

                Flow {
                    spacing: 2

                    ButtonGroup {
                        id: addKeypairStateButtonGroup
                    }

                    Repeater {
                        model: [
                            { value: Onboarding.AddKeyPairState.InProgress, text: "InProgress" },
                            { value: Onboarding.AddKeyPairState.Success, text: "Success" },
                            { value: Onboarding.AddKeyPairState.Failed, text: "Failed" }
                        ]

                        RoundButton {
                            text: modelData.text
                            checkable: true
                            checked: store.addKeyPairState === modelData.value

                            ButtonGroup.group: addKeypairStateButtonGroup

                            onClicked: store.addKeyPairState = modelData.value
                        }
                    }
                }

                ToolSeparator {}

                Label {
                    text: "Sync state:"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 2

                    ButtonGroup {
                        id: syncStateButtonGroup
                    }

                    Repeater {
                        model: [
                            { value: Onboarding.SyncState.InProgress, text: "InProgress" },
                            { value: Onboarding.SyncState.Success, text: "Success" },
                            { value: Onboarding.SyncState.Failed, text: "Failed" }
                        ]

                        RoundButton {
                            text: modelData.text
                            checkable: true
                            checked: store.syncState === modelData.value

                            ButtonGroup.group: syncStateButtonGroup

                            onClicked: store.syncState = modelData.value
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1-25&node-type=canvas&m=dev
