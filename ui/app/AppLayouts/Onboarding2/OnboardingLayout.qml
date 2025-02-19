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

    property bool biometricsAvailable: Qt.platform.os === Constants.mac

    property bool isBiometricsLogin // FIXME should come from the loginAccountsModel for each profile separately?

    property bool networkChecksEnabled: true
    property alias keycardPinInfoPageDelay: onboardingFlow.keycardPinInfoPageDelay

    readonly property alias stack: onboardingFlow
    readonly property string currentPageName: stack.topLevelItem ? Utils.objectTypeName(stack.topLevelItem) : ""

    signal shareUsageDataRequested(bool enabled)

    // flow: Onboarding.OnboardingFlow
    signal finished(int flow, var data)

    signal biometricsRequested(string profileId)
    signal dismissBiometricsRequested

    // -> "keyUid:string": User ID to login; "method:int": password or keycard (cf Onboarding.LoginMethod.*) enum;
    //    "data:var": contains "password" or "pin"
    signal loginRequested(string keyUid, int method, var data)

    function restartFlow() {
        unload()
        onboardingFlow.restart()
    }

    function unload() {
        onboardingFlow.clear()
        d.resetState()
    }

    function setBiometricResponse(secret: string, error = "",
                                  detailedError = "",
                                  wrongFingerprint = false) {
        onboardingFlow.setBiometricResponse(secret, error, detailedError,
                                            wrongFingerprint)
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
        property string keyUid // Used in LoginWithLostKeycardSeedphrase

        // login screen state
        property string selectedProfileKeyId

        function resetState() {
            d.password = ""
            d.keycardPin = ""
            d.enableBiometrics = false
            d.seedphrase = ""
            d.keyUid = ""
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
                keyUid: d.keyUid,
                enableBiometrics: d.enableBiometrics
            }

            root.finished(flow, data)
        }

        function loadMnemonic() {
            root.onboardingStore.loadMnemonic(d.seedphrase)
        }

        function authorize(pin) {
            if (!pin && !d.keycardPin) {
                console.warn("OnboardingLayout: authorize pin not provided")
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

    OnboardingFlow {
        id: onboardingFlow

        anchors.fill: parent

        loginAccountsModel: root.onboardingStore.loginAccountsModel

        keycardState: root.onboardingStore.keycardState
        pinSettingState: root.onboardingStore.pinSettingState
        authorizationState: root.onboardingStore.authorizationState
        restoreKeysExportState: root.onboardingStore.restoreKeysExportState
        syncState: root.onboardingStore.syncState
        addKeyPairState: root.onboardingStore.addKeyPairState

        generateMnemonic: root.onboardingStore.generateMnemonic

        displayKeycardPromoBanner: !d.settings.keycardPromoShown
        isBiometricsLogin: root.isBiometricsLogin
        biometricsAvailable: root.biometricsAvailable
        networkChecksEnabled: root.networkChecksEnabled

        passwordStrengthScoreFunction: root.onboardingStore.getPasswordStrengthScore
        isSeedPhraseValid: root.onboardingStore.validMnemonic
        isSeedPhraseDuplicate: root.onboardingStore.isMnemonicDuplicate
        validateConnectionString: root.onboardingStore.validateLocalPairingConnectionString
        tryToSetPukFunction: root.onboardingStore.setPuk
        remainingPinAttempts: root.onboardingStore.keycardRemainingPinAttempts
        remainingPukAttempts: root.onboardingStore.keycardRemainingPukAttempts

        onBiometricsRequested: (profileId) => root.biometricsRequested(profileId)
        onDismissBiometricsRequested: root.dismissBiometricsRequested()
        onLoginRequested: (keyUid, method, data) => root.loginRequested(keyUid, method, data)

        onSetPinRequested: (pin) => {
            d.keycardPin = pin
            root.onboardingStore.setPin(pin)
        }

        onLoadMnemonicRequested: d.loadMnemonic()
        onAuthorizationRequested: d.authorize(pin)
        onShareUsageDataRequested: (enabled) => root.shareUsageDataRequested(enabled)
        onPerformKeycardFactoryResetRequested: root.onboardingStore.startKeycardFactoryReset()
        onSyncProceedWithConnectionString: (connectionString) =>
            root.onboardingStore.inputConnectionStringForBootstrapping(connectionString)
        onSeedphraseSubmitted: (seedphrase) => d.seedphrase = seedphrase
        onKeyUidSubmitted: (keyUid) => d.keyUid = keyUid
        onSetPasswordRequested: (password) => d.password = password
        onEnableBiometricsRequested: (enabled) => d.enableBiometrics = enabled
        onLinkActivated: (link) => Qt.openUrlExternally(link)
        onExportKeysRequested: root.onboardingStore.exportRecoverKeys()
        onFinished: (flow) => d.finishFlow(flow)
    }

    // needs to be on top of the stack
    // we're here only to provide the Back button feature
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        cursorShape: undefined // don't override the cursor coming from the stack
        enabled: backButton.visible
        onClicked: onboardingFlow.popTopLevelItem()
    }

    StatusBackButton {
        id: backButton

        width: 44
        height: 44
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Theme.padding

        opacity: onboardingFlow.depth > 1 && !onboardingFlow.topLevelStack.busy &&
                 onboardingFlow.backAvailable ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        onClicked: onboardingFlow.popTopLevelItem()
    }

    Connections {
        target: onboardingFlow.topLevelItem
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

            if (!loginScreen)
                return

            loginScreen.setAccountLoginError(error, wrongPassword)
        }
    }

    Component.onCompleted: restartFlow()
}
