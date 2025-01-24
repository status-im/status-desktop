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

    // flow: Onboarding.SecondaryFlow
    signal finished(int flow, var data)

    // -> "keyUid:string": User ID to login; "method:int": password or keycard (cf Onboarding.LoginMethod.*) enum;
    //    "data:var": contains "password" or "pin"
    signal loginRequested(string keyUid, int method, var data)

    signal reloadKeycardRequested()

    function restartFlow() {
        unload()

        if (!loginAccountsModel || loginAccountsModel.ModelCount.empty)
            onboardingFlow.init()
        else
            stack.push(loginScreenComponent)
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

        function resetState() {
            d.password = ""
            d.keycardPin = ""
            d.enableBiometrics = false
            d.seedphrase = ""
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
    }

    background: Rectangle {
        color: Theme.palette.background
    }

    // page stack
    OnboardingStackView {
        id: stack

        objectName: "stack"
        anchors.fill: parent

        readonly property bool backAvailable:
            stack.currentItem ? (stack.currentItem.backAvailableHint ?? true)
                              : false
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

        keycardState: root.onboardingStore.keycardState
        syncState: root.onboardingStore.syncState
        addKeyPairState: root.onboardingStore.addKeyPairState

        seedWords: root.onboardingStore.getMnemonic().split(" ")

        displayKeycardPromoBanner: !d.settings.keycardPromoShown
        biometricsAvailable: root.biometricsAvailable
        networkChecksEnabled: root.networkChecksEnabled

        passwordStrengthScoreFunction: root.onboardingStore.getPasswordStrengthScore
        isSeedPhraseValid: root.onboardingStore.validMnemonic
        validateConnectionString: root.onboardingStore.validateLocalPairingConnectionString
        tryToSetPinFunction: root.onboardingStore.setPin
        remainingAttempts: root.onboardingStore.keycardRemainingPinAttempts

        onKeycardPinCreated: (pin) => {
            d.keycardPin = pin
            root.onboardingStore.setPin(pin)
        }

        onKeycardPinEntered: (pin) => {
            d.keycardPin = pin
            root.onboardingStore.setPin(pin)
        }

        onKeyPairTransferRequested: root.onboardingStore.startKeypairTransfer()
        onShareUsageDataRequested: (enabled) => root.shareUsageDataRequested(enabled)
        onReloadKeycardRequested: root.reloadKeycardRequested()
        onMnemonicWasShown: root.onboardingStore.mnemonicWasShown()
        onMnemonicRemovalRequested: root.onboardingStore.removeMnemonic()

        onSyncProceedWithConnectionString: (connectionString) =>
            root.onboardingStore.inputConnectionStringForBootstrapping(connectionString)
        onSeedphraseSubmitted: (seedphrase) => d.seedphrase = seedphrase
        onSetPasswordRequested: (password) => d.password = password
        onEnableBiometricsRequested: (enabled) => d.enableBiometrics = enabled
        onFinished: (flow) => d.finishFlow(flow)
        onKeycardFactoryResetRequested: ; // TODO invoke external popup and finish the flow
    }

    Component {
        id: loginScreenComponent
        LoginScreen {
            onboardingStore: root.onboardingStore
            loginAccountsModel: root.loginAccountsModel
            biometricsAvailable: root.biometricsAvailable
            isBiometricsLogin: root.isBiometricsLogin
            onBiometricsRequested: root.biometricsRequested()
            onLoginRequested: (keyUid, method, data) => root.loginRequested(keyUid, method, data)

            onOnboardingCreateProfileFlowRequested: onboardingFlow.startCreateProfileFlow()
            onOnboardingLoginFlowRequested: onboardingFlow.startLoginFlow()
            onUnlockWithSeedphraseRequested: console.warn("!!! FIXME onUnlockWithSeedphraseRequested")
            onUnlockWithPukRequested: console.warn("!!! FIXME onUnlockWithPukRequested")
            onLostKeycard: onboardingFlow.startLostKeycardFlow()
        }
    }

    Connections {
        target: stack.currentItem
        ignoreUnknownSignals: true

        function onOpenLink(link: string) {
            Global.openLink(link)
        }
        function onOpenLinkWithConfirmation(link: string, domain: string) {
            Global.openLinkWithConfirmation(link, domain)
        }
    }

    Component.onCompleted: restartFlow()
}
