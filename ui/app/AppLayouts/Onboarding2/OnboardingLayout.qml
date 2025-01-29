import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding2.stores 1.0
import AppLayouts.Onboarding.enums 1.0

import utils 1.0

Page {
    id: root

    required property OnboardingStore onboardingStore

    // [{keyUid:string, username:string, thumbnailImage:string, colorId:int, colorHash:var, order:int, keycardCreatedAccount:bool}]
    // NB: this also decides whether we show the Login screen (if not empty), or the Onboarding
    required property var loginAccountsModel

    property bool biometricsAvailable: Qt.platform.os === Constants.mac
    property bool isBiometricsLogin // FIXME should come from the loginAccountsModel for each profile separately?
    signal biometricsRequested() // emitted when the user wants to try the biometrics prompt again

    property bool networkChecksEnabled: true
    property alias keycardPinInfoPageDelay: onboardingFlow.keycardPinInfoPageDelay

    readonly property alias stack: stack
    readonly property string currentPageName: stack.currentItem ? Utils.objectTypeName(stack.currentItem) : ""

    signal shareUsageDataRequested(bool enabled)

    // flow: Onboarding.OnboardingFlow
    signal finished(int flow, var data)

    // -> "keyUid:string": User ID to login; "method:int": password or keycard (cf Onboarding.LoginMethod.*) enum;
    //    "data:var": contains "password" or "pin"
    signal loginRequested(string keyUid, int method, var data)

    signal reloadKeycardRequested()

    function restartFlow() {
        unload()
        onboardingFlow.init()
    }

    function unload() {
        stack.clear()
        d.resetState()
    }

    QtObject {
        id: d

        // constants
        readonly property int numWordsToVerify: 4

        // state collected
        property string password
        property string keycardPin
        property bool enableBiometrics
        property string seedphrase

        // login screen state
        property string selectedProfileKeyId

        function resetState() {
            d.password = ""
            d.keycardPin = ""
            d.enableBiometrics = false
            d.seedphrase = ""
            d.selectedProfileKeyId = ""
        }

        readonly property Settings settings: Settings {
            property bool keycardPromoShown // whether we've seen the keycard promo banner on KeycardIntroPage

            function reset() {
                keycardPromoShown = false
            }
        }

        function finishFlow(flow) {
            const data = {
                password: d.password,
                keycardPin: d.keycardPin,
                seedphrase: d.seedphrase,
                enableBiometrics: d.enableBiometrics
            }

            root.finished(flow, data)
        }

        function loadMnemonic() {
            root.onboardingStore.loadMnemonic(d.seedphrase)
        }

        function authorize(pin) {
            if (!pin && !d.keycardPin) {
                return
            }
            if (!pin) {
                pin = d.keycardPin
            }
            root.onboardingStore.authorize(pin)
        }
    }

    background: Rectangle {
        color: Theme.palette.background
    }

    // page stack
    OnboardingStackView {
        id: stack

        objectName: "stack"
        anchors.fill: parent
    }

    // needs to be on top of the stack
    // we're here only to provide the Back button feature
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        cursorShape: undefined // don't override the cursor coming from the stack
        enabled: stack.depth > 1 && !stack.busy
        onClicked: stack.pop()
    }

    StatusBackButton {
        width: 44
        height: 44
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Theme.padding

        opacity: stack.depth > 1 && !stack.busy && stack.backAvailable ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        onClicked: stack.pop()
    }

    OnboardingFlow {
        id: onboardingFlow

        stackView: stack

        loginAccountsModel: root.loginAccountsModel

        keycardState: root.onboardingStore.keycardState
        pinSettingState: root.onboardingStore.pinSettingState
        authorizationState: root.onboardingStore.authorizationState
        restoreKeysExportState: root.onboardingStore.restoreKeysExportState
        syncState: root.onboardingStore.syncState
        addKeyPairState: root.onboardingStore.addKeyPairState

        getSeedWords: root.onboardingStore.getMnemonic

        displayKeycardPromoBanner: !d.settings.keycardPromoShown
        isBiometricsLogin: root.isBiometricsLogin
        biometricsAvailable: root.biometricsAvailable
        networkChecksEnabled: root.networkChecksEnabled

        passwordStrengthScoreFunction: root.onboardingStore.getPasswordStrengthScore
        isSeedPhraseValid: root.onboardingStore.validMnemonic
        validateConnectionString: root.onboardingStore.validateLocalPairingConnectionString
        tryToSetPinFunction: root.onboardingStore.setPin
        tryToSetPukFunction: root.onboardingStore.setPuk
        remainingPinAttempts: root.onboardingStore.keycardRemainingPinAttempts
        remainingPukAttempts: root.onboardingStore.keycardRemainingPukAttempts

        onBiometricsRequested: root.biometricsRequested()
        onLoginRequested: (keyUid, method, data) => root.loginRequested(keyUid, method, data)

        onKeycardPinCreated: (pin) => {
            d.keycardPin = pin
            root.onboardingStore.setPin(pin)
        }

        onLoadMnemonicRequested: d.loadMnemonic()
        onAuthorizationRequested: d.authorize(pin)
        onShareUsageDataRequested: (enabled) => root.shareUsageDataRequested(enabled)
        onReloadKeycardRequested: root.reloadKeycardRequested()

        onSyncProceedWithConnectionString: (connectionString) =>
            root.onboardingStore.inputConnectionStringForBootstrapping(connectionString)
        onSeedphraseSubmitted: (seedphrase) => d.seedphrase = seedphrase
        onSetPasswordRequested: (password) => d.password = password
        onEnableBiometricsRequested: (enabled) => d.enableBiometrics = enabled
        onLinkActivated: (link) => Qt.openUrlExternally(link)
        onExportKeysRequested: root.onboardingStore.exportRecoverKeys()
        onFinished: (flow) => d.finishFlow(flow)
        onKeycardFactoryResetRequested: console.warn("!!! FIXME OnboardingLayout::onKeycardFactoryResetRequested")
    }

    Connections {
        target: stack.currentItem
        ignoreUnknownSignals: true

        function onOpenLink(link: string) {
            Qt.openUrlExternally(link)
        }
        function onOpenLinkWithConfirmation(link: string, domain: string) {
            Qt.openUrlExternally(link)
        }
    }

    Connections {
        target: root.onboardingStore

        // (password) login
        function onAccountLoginError(error: string, wrongPassword: bool) {
            const loginScreen = onboardingFlow.loginScreen

            if (!error || !loginScreen || loginScreen.currentProfileIsKeycard)
                return

            let validationError
            let detailedError

            // SQLITE_NOTADB: "file is not a database"
            if (error.includes("file is not a database") || wrongPassword) {
                validationError = qsTr("Password incorrect. %1").arg("<a href='#password'>" + qsTr("Forgot password?") + "</a>")
                detailedError = ""
            } else {
                validationError = qsTr("Login failed. %1").arg("<a href='#details'>" + qsTr("Show details.") + "</a>")
                detailedError = error
            }

            loginScreen.setError(validationError, detailedError)
        }

        // biometrics
        function onObtainingPasswordError(errorDescription: string, errorType: string, wrongFingerprint: bool) {
            const loginScreen = onboardingFlow.loginScreen

            if (!loginScreen || errorType === Constants.keychain.errorType.authentication) {
                // We are notifying user only about keychain errors.
                return
            }

            const error = wrongFingerprint
                        ? qsTr("Fingerprint not recognised. Try entering password instead.")
                        : errorDescription

            loginScreen.setObtainingPasswordError(error, wrongFingerprint)
        }

        function onObtainingPasswordSuccess(password: string) {
            const loginScreen = onboardingFlow.loginScreen

            if (!loginScreen || !root.isBiometricsLogin)
                return

            loginScreen.setObtainingPasswordSuccess(password)
        }

        function onAccountLoginError(error: string, wrongPassword: bool) {
            const loginScreen = onboardingFlow.loginScreen

            if (!loginScreen)
                return

            loginScreen.setAccountLoginError(password, wrongPassword)
        }
    }

    Component.onCompleted: restartFlow()
}
