import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2.stores 1.0
import AppLayouts.Onboarding2.controls 1.0
import AppLayouts.Onboarding2.components 1.0

import utils 1.0

OnboardingPage {
    id: root

    required property int keycardState

    required property var tryToSetPinFunction
    required property int keycardRemainingPinAttempts
    required property int keycardRemainingPukAttempts

    // [{keyUid:string, username:string, thumbnailImage:string, colorId:int, colorHash:var, order:int, keycardCreatedAccount:bool}]
    required property var loginAccountsModel

    property bool biometricsAvailable: Qt.platform.os === Constants.mac
    required property bool isBiometricsLogin // FIXME should come from the loginAccountsModel for each profile separately?

    readonly property string selectedProfileKeyId: loginUserSelector.selectedProfileKeyId
    readonly property bool selectedProfileIsKeycard: d.currentProfileIsKeycard

    // emitted when the user wants to try the biometrics prompt again
    signal biometricsRequested()

    // -> "keyUid:string": User ID to login; "method:int": password or keycard (cf Onboarding.LoginMethod.*) enum;
    //    "data:var": contains "password" or "pin"
    signal loginRequested(string keyUid, int method, var data)

    // "internal" onboarding signals, starting other flows
    signal onboardingCreateProfileFlowRequested()
    signal onboardingLoginFlowRequested()
    signal unblockWithSeedphraseRequested()
    signal unblockWithPukRequested()
    signal lostKeycard()

    QtObject {
        id: d

        property bool biometricsSuccessful
        property bool biometricsFailed

        readonly property bool currentProfileIsKeycard: loginUserSelector.keycardCreatedAccount

        readonly property Settings settings: Settings {
            category: "Login"
            property string lastKeyUid
        }

        function resetBiometricsResult() {
            d.biometricsSuccessful = false
            d.biometricsFailed = false
        }

        function doPasswordLogin(password: string) {
            if (password.length === 0)
                return

            root.loginRequested(d.settings.lastKeyUid, Onboarding.LoginMethod.Password, { password })
        }

        function doKeycardLogin(pin: string) {
            if (pin.length === 0)
                return

            root.loginRequested(d.settings.lastKeyUid, Onboarding.LoginMethod.Keycard, { pin })
        }
    }

    Component.onCompleted: {
        loginUserSelector.setSelection(d.settings.lastKeyUid)
        if (!d.currentProfileIsKeycard)
            passwordBox.forceActiveFocus()
    }

    function setObtainingPasswordError(error: string, wrongFingerprint: bool) {
        d.biometricsSuccessful = false
        d.biometricsFailed = wrongFingerprint

        if (d.currentProfileIsKeycard) {
            keycardBox.clear()
        } else {
            passwordBox.validationError = error
            passwordBox.clear()
            passwordBox.forceActiveFocus()
        }
    }

    function setObtainingPasswordSuccess(password: string) {
        if (!root.isBiometricsLogin)
            return

        d.biometricsSuccessful = true
        d.biometricsFailed = false

        if (d.currentProfileIsKeycard) {
            keycardBox.setPin(password) // automatic login, emits loginRequested() already
        } else {
            passwordBox.validationError = ""
            passwordBox.password = password
            d.doPasswordLogin(password)
        }
    }

    function setError(error: string, detailedError: string) {
        passwordBox.validationError = error
        passwordBox.detailedError = detailedError
    }

    // (password) login
    function setAccountLoginError(error: string, wrongPassword: bool) {
        if (!error) {
            return
        }

        if (d.currentProfileIsKeycard) {
            // Login with keycard
            if (wrongPassword) {
                keycardBox.markAsWrongPin()
            } else {
                keycardBox.loginError = error
            }
            return
        }

        // Login with password
        if (wrongPassword) {
            passwordBox.validationError = qsTr("Password incorrect. %1").arg("<a href='#password'>" + qsTr("Forgot password?") + "</a>")
            passwordBox.detailedError = ""
        } else {
            passwordBox.validationError = qsTr("Login failed. %1").arg("<a href='#details'>" + qsTr("Show details.") + "</a>")
            passwordBox.detailedError = error
        }

        passwordBox.clear()
        passwordBox.forceActiveFocus()
    }

    padding: 40

    contentItem: Item {
        ColumnLayout {
            width: Math.min(340, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 200
            anchors.bottom: parent.bottom
            spacing: Theme.padding

            StatusImage {
                Layout.preferredWidth: 90
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter
                source: Theme.png("status")
                mipmap: true
            }

            StatusBaseText {
                id: headerText
                Layout.fillWidth: true
                text: qsTr("Welcome back")
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            LoginUserSelector {
                id: loginUserSelector
                objectName: "loginUserSelector"
                Layout.topMargin: 20
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                model: root.loginAccountsModel
                currentKeycardLocked: root.keycardState === Onboarding.KeycardState.BlockedPIN ||
                                      root.keycardState === Onboarding.KeycardState.BlockedPUK
                onSelectedProfileKeyIdChanged: {
                    d.resetBiometricsResult()
                    d.settings.lastKeyUid = selectedProfileKeyId

                    if (d.currentProfileIsKeycard) {
                       keycardBox.clear()
                    } else {
                       passwordBox.validationError = ""
                       passwordBox.clear()
                       passwordBox.forceActiveFocus()
                    }
                }
                onOnboardingCreateProfileFlowRequested: root.onboardingCreateProfileFlowRequested()
                onOnboardingLoginFlowRequested: root.onboardingLoginFlowRequested()
            }

            LoginPasswordBox {
                Layout.fillWidth: true
                id: passwordBox
                objectName: "passwordBox"
                visible: !d.currentProfileIsKeycard
                enabled: !!loginUserSelector.selectedProfileKeyId
                isBiometricsLogin: root.biometricsAvailable && root.isBiometricsLogin
                biometricsSuccessful: d.biometricsSuccessful
                biometricsFailed: d.biometricsFailed
                onPasswordEditedManually: {
                    // reset state when typing the pass manually; not to break the bindings inside the component
                    validationError = ""
                    d.resetBiometricsResult()
                }
                onBiometricsRequested: root.biometricsRequested()
                onLoginRequested: (password) => d.doPasswordLogin(password)
            }

            LoginKeycardBox {
                Layout.fillWidth: true
                id: keycardBox
                objectName: "keycardBox"
                visible: d.currentProfileIsKeycard
                isBiometricsLogin: root.biometricsAvailable && root.isBiometricsLogin
                biometricsSuccessful: d.biometricsSuccessful
                biometricsFailed: d.biometricsFailed
                keycardState: root.keycardState
                keycardRemainingPinAttempts: root.keycardRemainingPinAttempts
                keycardRemainingPukAttempts: root.keycardRemainingPukAttempts
                onUnblockWithSeedphraseRequested: root.unblockWithSeedphraseRequested()
                onUnblockWithPukRequested: root.unblockWithPukRequested()
                onPinEditedManually: {
                    // reset state when typing the PIN manually; not to break the bindings inside the component
                    d.resetBiometricsResult()
                }
                onBiometricsRequested: root.biometricsRequested()
                onLoginRequested: (pin) => d.doKeycardLogin(pin)
            }

            Item { Layout.fillHeight: true }

            StatusButton {
                objectName: "lostKeycardButon"

                Layout.alignment: Qt.AlignHCenter

                isOutline: true
                size: StatusBaseButton.Size.Small
                visible: d.currentProfileIsKeycard
                text: qsTr("Lost this Keycard?")

                onClicked: root.lostKeycard()
            }
        }
    }
}
