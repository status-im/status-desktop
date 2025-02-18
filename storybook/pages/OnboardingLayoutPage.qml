import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import StatusQ.Core.Backpressure 0.1

import Qt.labs.settings 1.0

import StatusQ 0.1

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2 1.0
import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding2.stores 1.0

import shared.panels 1.0
import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: mockDriver

        readonly property string mnemonic: "apple banana cat cow catalog catch category cattle dog elephant fish grape"
        readonly property string pin: "111111"
        readonly property string puk: "111111111111"
        readonly property string password: "somepassword"
    }

    function restart() {
        store.keycardState = Onboarding.KeycardState.NoPCSCService
        store.addKeyPairState = Onboarding.ProgressState.Idle
        store.pinSettingState = Onboarding.ProgressState.Idle
        store.authorizationState = Onboarding.AuthorizationState.Idle
        store.restoreKeysExportState = Onboarding.ProgressState.Idle
        store.syncState = Onboarding.ProgressState.Idle
        store.keycardRemainingPinAttempts = Constants.onboarding.defaultPinAttempts
        store.keycardRemainingPukAttempts = Constants.onboarding.defaultPukAttempts

        onboarding.restartFlow()
    }

    LoginAccountsModel {
        id: loginAccountsModel
    }

    ListModel {
        id: emptyModel
    }

    OnboardingLayout {
        id: onboarding

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        readonly property Item currentPage: {
            if (stack.topLevelItem instanceof Loader)
                return stack.topLevelItem.item

            return stack.topLevelItem
        }

        onboardingStore: OnboardingStore {
            id: store

            property int keycardState: Onboarding.KeycardState.NoPCSCService
            property int addKeyPairState: Onboarding.ProgressState.Idle
            property int pinSettingState: Onboarding.ProgressState.Idle
            property int authorizationState: Onboarding.AuthorizationState.Idle
            property int restoreKeysExportState: Onboarding.ProgressState.Idle
            property int syncState: Onboarding.ProgressState.Idle
            property var loginAccountsModel: ctrlLoginScreen.checked ? loginAccountsModel : emptyModel

            property int keycardRemainingPinAttempts: Constants.onboarding.defaultPinAttempts
            property int keycardRemainingPukAttempts: Constants.onboarding.defaultPukAttempts

            function setPin(pin: string) {
                logs.logEvent("OnboardingStore.setPin", ["pin"], arguments)
                ctrlLoginResult.result = "🯄"
                const valid = pin === mockDriver.pin
                if (!valid)
                    keycardRemainingPinAttempts--
                if (keycardRemainingPinAttempts <= 0) { // SIMULATION: "block" the keycard
                    keycardState = Onboarding.KeycardState.BlockedPIN
                    keycardRemainingPinAttempts = 0
                }
            }

            function setPuk(puk: string) { // -> bool
                logs.logEvent("OnboardingStore.setPuk", ["puk"], arguments)
                const valid = puk === mockDriver.puk
                if (!valid)
                    keycardRemainingPukAttempts--
                if (keycardRemainingPukAttempts <= 0) { // SIMULATION: "block" the keycard
                    keycardState = Onboarding.KeycardState.BlockedPUK
                    keycardRemainingPukAttempts = 0
                }
                return valid
            }

            function authorize(pin: string) {
                logs.logEvent("OnboardingStore.authorize", ["pin"], arguments)
                if (pin === mockDriver.pin)
                    authorizationState = Onboarding.AuthorizationState.Authorized
                else
                    authorizationState = Onboarding.AuthorizationState.WrongPin
            }

            function loadMnemonic(mnemonic: string) { // -> void
                logs.logEvent("OnboardingStore.loadMnemonic", ["mnemonic"], arguments)
            }

            function exportRecoverKeys() { // -> void
                logs.logEvent("OnboardingStore.exportRecoverKeys")
            }

            function startKeycardFactoryReset() {
                logs.logEvent("OnboardingStore.startKeycardFactoryReset")
                console.warn("!!! SIMULATION: KEYCARD FACTORY RESET")
                keycardState = Onboarding.KeycardState.FactoryResetting // SIMULATION: factory reset
                Backpressure.debounce(root, 2000, () => {
                    keycardState = Onboarding.KeycardState.Empty
                })()
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

            function isMnemonicDuplicate(mnemonic: string) { // -> bool
                logs.logEvent("OnboardingStore.isMnemonicDuplicate", ["mnemonic"], arguments)
                return false
            }

            function generateMnemonic() { // -> string
                logs.logEvent("OnboardingStore.generateMnemonic()")
                return mockDriver.mnemonic
            }

            function validateLocalPairingConnectionString(connectionString: string) { // -> bool
                logs.logEvent("OnboardingStore.validateLocalPairingConnectionString", ["connectionString"], arguments)
                return !Number.isNaN(parseInt(connectionString))
            }

            function inputConnectionStringForBootstrapping(connectionString: string) { // -> void
                logs.logEvent("OnboardingStore.inputConnectionStringForBootstrapping", ["connectionString"], arguments)
            }

            // password signals
            signal accountLoginError(string error, bool wrongPassword)
        }

        keychain: keychain

        biometricsAvailable: ctrlBiometrics.checked

        onFinished: (flow, data) => {
            console.warn("!!! ONBOARDING FINISHED; flow:", flow, "; data:", JSON.stringify(data))
            logs.logEvent("onFinished", ["flow", "data"], arguments)

            console.warn("!!! SIMULATION: SHOWING SPLASH")
            stack.clear()
            stack.push(splashScreen, { runningProgressAnimation: true })
        }

        onLoginRequested: (keyUid, method, data) => {
            logs.logEvent("onLoginRequested", ["keyUid", "method", "data"], arguments)

            // SIMULATION: emit an error in case of wrong password or PIN
            if (method === Onboarding.LoginMethod.Password && data.password !== mockDriver.password) {
                onboardingStore.accountLoginError("The impossible has happened", Math.random() < 0.5) // randomly fail between a wrong pass and some other error
                ctrlLoginResult.result = "<font color='red'>⛔</font>"
            } else if (method === Onboarding.LoginMethod.Keycard && data.pin !== mockDriver.pin) {
                onboardingStore.keycardRemainingPinAttempts-- // SIMULATION: decrease the remaining PIN attempts
                if (onboardingStore.keycardRemainingPinAttempts <= 0) { // SIMULATION: "block" the keycard
                    onboardingStore.keycardState = Onboarding.KeycardState.BlockedPIN
                    onboardingStore.keycardRemainingPinAttempts = 0
                }
                onboardingStore.accountLoginError("", true)
                ctrlLoginResult.result = "<font color='red'>⛔</font>"
            } else {
                ctrlLoginResult.result = "<font color='green'>✔</font>"
            }
        }

        Button {
            text: "Paste password"
            focusPolicy: Qt.NoFocus

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.currentPage instanceof CreatePasswordPage ||
                     (onboarding.currentPage instanceof LoginScreen && !onboarding.currentPage.selectedProfileIsKeycard)

            onClicked: {
                const currentItem = onboarding.stack.currentItem

                const loginPassInput = StorybookUtils.findChild(
                                         currentItem,
                                         "loginPasswordInput")
                if (!!loginPassInput) {
                    ClipboardUtils.setText(mockDriver.password)
                    loginPassInput.paste()
                }

                const input1 = StorybookUtils.findChild(
                                 currentItem,
                                 "passwordViewNewPassword")
                const input2 = StorybookUtils.findChild(
                                 currentItem,
                                 "passwordViewNewPasswordConfirm")

                if (!input1 || !input2)
                    return

                input1.text = mockDriver.password
                input2.text = mockDriver.password
            }
        }

        Button {
            text: "Paste seed phrase"
            focusPolicy: Qt.NoFocus

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.currentPage instanceof SeedphrasePage

            onClicked: {
                const words = Utils.splitWords(mockDriver.mnemonic)

                for (let i = 1;; i++) {
                    const input = StorybookUtils.findChild(
                                    onboarding.currentPage,
                                    `enterSeedPhraseInputField${i}`)

                    if (input === null)
                        break

                    input.text = words[i - 1]
                }
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.currentPage instanceof KeycardEnterPinPage ||
                     onboarding.currentPage instanceof KeycardCreatePinPage ||
                     (onboarding.currentPage instanceof LoginScreen && onboarding.currentPage.selectedProfileIsKeycard && store.keycardState === Onboarding.KeycardState.NotEmpty)

            text: "Copy valid PIN (\"%1\")".arg(mockDriver.pin)
            focusPolicy: Qt.NoFocus
            onClicked: ClipboardUtils.setText(mockDriver.pin)
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.currentPage instanceof KeycardEnterPukPage

            text: "Copy valid PUK (\"%1\")".arg(mockDriver.puk)
            focusPolicy: Qt.NoFocus
            onClicked: ClipboardUtils.setText(mockDriver.puk)
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.currentPage instanceof BackupSeedphraseVerify

            text: "Paste seed phrase verification"
            focusPolicy: Qt.NoFocus
            onClicked: {
                const words = Utils.splitWords(mockDriver.mnemonic)

                for (let i = 0;; i++) {
                    const input = StorybookUtils.findChild(
                                    onboarding.currentPage,
                                    `seedInput_${i}`)

                    if (input === null)
                        break

                    const index = input.seedWordIndex
                    input.text = words[index]
                }
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            visible: onboarding.currentPage instanceof BackupSeedphraseAcks

            text: "Paste seed phrase verification"
            focusPolicy: Qt.NoFocus
            onClicked: {
                for (let i = 1;; i++) {
                    const checkBox = StorybookUtils.findChild(
                                       onboarding.currentPage,
                                       `ack${i}`)

                    if (checkBox === null)
                        break

                    checkBox.checked = true
                }
            }
        }
    }

    KeychainMock {
        id: keychain

        parent: root

        readonly property alias touchIdChecked: ctrlTouchIdUser.checked
        onTouchIdCheckedChanged: onboarding.keychainChanged()

        function hasCredential(account) {
            const isKeycard = onboarding.currentPage instanceof LoginScreen
                            && onboarding.currentPage.selectedProfileIsKeycard

            keychain.saveCredential(account, isKeycard ? mockDriver.pin : mockDriver.password)

            return touchIdChecked ? Keychain.StatusSuccess
                                  : Keychain.StatusNotFound
        }
    }

    Component {
        id: splashScreen

        DidYouKnowSplashScreen {
            property bool runningProgressAnimation

            NumberAnimation on progress {
                from: 0.0
                to: 1
                duration: 3000
                running: runningProgressAnimation
                onStopped: {
                    console.warn("!!! SPLASH SCREEN DONE")
                    console.warn("!!! RESTARTING FLOW")
                    root.restart()
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 300
        SplitView.preferredHeight: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            spacing: 10

            TextField {
                Layout.fillWidth: true

                function stackToText(stack) {
                    let content = ""

                    for (let i = 0; i < stack.depth; i++) {
                        const stackEntry = stack.get(i, StackView.ForceLoad)

                        if (stackEntry instanceof StackView)
                            content += " [" + InspectionUtils.baseName(stackEntry) + ": " + stackToText(stackEntry) + "]"
                        else
                            content += " " + InspectionUtils.baseName(stackEntry instanceof Loader
                                                                    ? stackEntry.item : stackEntry)
                    }

                    return content
                }

                text: {
                    const stack = onboarding.stack

                    // trigger change when only curret item changes on replace
                    stack.topLevelItem

                    return `Stack (${stack.totalDepth}): ${stackToText(stack)}`
                }

                background: null
                readOnly: true
                selectByMouse: true
                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Restart"
                    focusPolicy: Qt.NoFocus
                    onClicked: root.restart()
                }

                Switch {
                    id: ctrlBiometrics
                    text: "Biometrics available"
                    checked: true
                }

                ToolSeparator {}

                Switch {
                    id: ctrlLoginScreen
                    text: "Show login screen"
                    checkable: true
                    onToggled: root.restart()
                }

                Switch {
                    id: ctrlTouchIdUser
                    text: "Touch ID login"
                    visible: ctrlLoginScreen.checked
                    enabled: ctrlBiometrics.checked
                    checked: ctrlBiometrics.checked
                }

                Text {
                    id: ctrlLoginResult
                    property string result: "🯄"
                    visible: ctrlLoginScreen.checked
                    text: "Login result: %1".arg(result)
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
                        model: Onboarding.getModelFromEnum("KeycardState")

                        RoundButton {
                            text: modelData.name
                            checkable: true
                            checked: store.keycardState === modelData.value

                            ButtonGroup.group: keycardStateButtonGroup

                            onClicked: {
                                store.keycardState = modelData.value
                                ctrlLoginResult.result = "🯄"
                            }
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
                        model: Onboarding.getModelFromEnum("ProgressState")

                        RoundButton {
                            text: modelData.name
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
                    spacing: 2

                    ButtonGroup {
                        id: syncStateButtonGroup
                    }

                    Repeater {
                        model: Onboarding.getModelFromEnum("LocalPairingState")

                        RoundButton {
                            text: modelData.name
                            checkable: true
                            checked: store.syncState === modelData.value

                            ButtonGroup.group: syncStateButtonGroup

                            onClicked: store.syncState = modelData.value
                        }
                    }
                }

                ToolSeparator {}

                Label {
                    text: "PIN Setting state:"
                }

                Flow {
                    spacing: 2

                    ButtonGroup {
                        id: pinSettingStateButtonGroup
                    }

                    Repeater {
                        model: Onboarding.getModelFromEnum("ProgressState")

                        RoundButton {
                            text: modelData.name
                            checkable: true
                            checked: store.pinSettingState === modelData.value

                            ButtonGroup.group: pinSettingStateButtonGroup

                            onClicked: store.pinSettingState = modelData.value
                        }
                    }
                }
            }

            RowLayout {
                Label {
                    text: "Authorization state:"
                }

                Flow {
                    spacing: 2

                    ButtonGroup {
                        id: authorizationStateButtonGroup
                    }

                    Repeater {
                        model: Onboarding.getModelFromEnum("AuthorizationState")

                        RoundButton {
                            text: modelData.name
                            checkable: true
                            checked: store.authorizationState === modelData.value

                            ButtonGroup.group: authorizationStateButtonGroup

                            onClicked: store.authorizationState = modelData.value
                        }
                    }
                }

                ToolSeparator {}

                Label {
                    text: "Restore Keys Export state:"
                }

                Flow {
                    spacing: 2

                    ButtonGroup {
                        id: restoreKeysExportStateButtonGroup
                    }

                    Repeater {
                        model: Onboarding.getModelFromEnum("ProgressState")

                        RoundButton {
                            text: modelData.name
                            checkable: true
                            checked: store.restoreKeysExportState === modelData.value

                            ButtonGroup.group: restoreKeysExportStateButtonGroup

                            onClicked: store.restoreKeysExportState = modelData.value
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Settings {
        property alias useBiometrics: ctrlBiometrics.checked
        property alias showLoginScreen: ctrlLoginScreen.checked
        property alias useTouchId: ctrlTouchIdUser.checked
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=1-25&node-type=canvas&m=dev
