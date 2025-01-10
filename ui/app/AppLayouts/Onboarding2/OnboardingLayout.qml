import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1

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
    property bool networkChecksEnabled: true
    property alias keycardPinInfoPageDelay: onboardingFlow.keycardPinInfoPageDelay

    readonly property alias stack: stack

    signal shareUsageDataRequested(bool enabled)

    // flow: Onboarding.SecondaryFlow
    signal finished(int flow, var data)

    function restartFlow() {
        stack.clear()
        d.resetState()
        d.settings.reset()
        onboardingFlow.init()
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

    // page stack
    OnboardingStackView {
        id: stack

        objectName: "stack"
        anchors.fill: parent

        readonly property bool backAvailable:
            stack.currentItem ? (stack.currentItem.backAvailableHint ?? true)
                              : false
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
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
        onSyncProceedWithConnectionString: (connectionString) =>
            root.onboardingStore.inputConnectionStringForBootstrapping(connectionString)
        onSeedphraseSubmitted: (seedphrase) => d.seedphrase = seedphrase
        onSetPasswordRequested: (password) => d.password = password
        onEnableBiometricsRequested: (enabled) => d.enableBiometrics = enabled
        onFinished: (flow) => d.finishFlow(flow)
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

    Component.onCompleted: root.restartFlow()
}
