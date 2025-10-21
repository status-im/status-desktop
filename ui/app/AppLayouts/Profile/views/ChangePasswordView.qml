import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import shared.panels
import shared.controls
import shared.stores
import shared.views
import utils

import StatusQ
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Components
import StatusQ.Popups
import StatusQ.Popups.Dialog

import AppLayouts.Profile.popups
import AppLayouts.Profile.stores

SettingsContentBase {
    id: root

    property PrivacyStore privacyStore
    required property Keychain keychain

    QtObject {
        id: d

        readonly property int maxContentWidth: 507 // By design

        // Read-only flag that turns true when the footer row component enters a “compact” layout automatically on resize.
        readonly property bool compactFooterMode: flatButton.implicitWidth + confirmBtnFirstRowItem.implicitWidth + 2 * Theme.padding > root.width

        property int reevaluateTrigger
        function reevaluateHasCredential() {
            reevaluateTrigger++
        }

        readonly property bool biometricsEnabled: {
            reevaluateTrigger // Reference for binding
            return keychain.hasCredential(privacyStore.keyUid) === Keychain.StatusSuccess
        }

        function showErrorToast() {
            Global.displayToastMessage(
                        qsTr("Failed to enable biometric login and transaction authentication for this device"),
                        "", "warning", false, Constants.ephemeralNotificationType.danger, "")
        }

        function showSuccessToast() {
            Global.displayToastMessage(
                        qsTr("Biometric login and transaction authentication enabled for this device"),
                        "", "checkmark-circle", false, Constants.ephemeralNotificationType.success, "")
        }
    }

    readonly property Item biometricsPopup: titleRowComponentLoader.item
    readonly property Connections privacyStoreConnections: Connections {
        target: root.privacyStore.privacyModule

        function onSaveBiometricsRequested(keyUid, credential) {
            // If Password not retrieved
            if (keyUid === "" || credential === "") {
                d.showErrorToast()
                return
            }

            const status = keychain.saveCredential(keyUid, credential)

            if (status !== Keychain.StatusSuccess) {
                d.showErrorToast()
                return
            }

            d.reevaluateHasCredential()
        }
    }
    readonly property Connections keychainConnections: Connections {
        target: root.keychain

        function onCredentialSaved(account: string) {
            d.showSuccessToast()
            d.reevaluateHasCredential()
        }

        function onGetCredentialRequestCompleted(status, secret) {
            if (status !== Keychain.StatusSuccess) {
                d.showErrorToast()
            }
            d.reevaluateHasCredential()
        }
    }

    property var passwordStrengthScoreFunction: function () {}

    titleRowComponentLoader.sourceComponent: StatusSwitch {
        id: biometricsSwitch

        LayoutMirroring.enabled: true
        LayoutMirroring.childrenInherit: true

        visible: (Qt.platform.os === SQUtils.Utils.mac || SQUtils.Utils.isMobile) && root.keychain.available

        text: qsTr("Enable biometrics")
        textColor: Theme.palette.baseColor1

        checkable: false
        checked: root.keychain.available && d.biometricsEnabled
        onClicked: {
            // Enable Biometrics flow
            if (!biometricsSwitch.checked) {
                root.privacyStore.tryStoreToKeyChain()
                return
            }

            // Disable biometrics flow
            const status = root.keychain.deleteCredential(root.privacyStore.keyUid)

            switch (status) {
            case Keychain.StatusSuccess:
                Global.displayToastMessage(
                            qsTr("Biometric login and transaction authentication disabled for this device"),
                            "", "checkmark-circle", false, Constants.ephemeralNotificationType.success, "")
                break
            default:
                Global.displayToastMessage(
                            qsTr("Failed to disable biometric login and transaction authentication for this device"),
                            errorDescription, "warning", false, Constants.ephemeralNotificationType.danger, "")
            }
            d.reevaluateHasCredential()
        }
        StatusToolTip {
            x: 15
            orientation: StatusToolTip.Bottom
            visible: (!root.checked && biometricsSwitch.hovered)
            text: qsTr("Biometric login and transaction authentication")
        }
    }

    ColumnLayout {
        width: Math.min(d.maxContentWidth, root.contentWidth)
        PasswordView {
            id: choosePasswordForm

            Layout.fillWidth: true

            createNewPsw: false
            title: qsTr("Change your password")
            titleSize: 17
            contentAlignment: Qt.AlignLeft
            highSizeIntro: true
            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

            onReturnPressed: {
                if (ready) {
                    confirmPasswordChangePopup.open();
                }
            }
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
        }

        RowLayout {
            Layout.fillWidth: true

            StatusFlatButton {
                id: flatButton
                text: qsTr("Clear & cancel")
                onClicked: choosePasswordForm.reset()
            }

            Item { Layout.fillWidth: true }

            LayoutItemProxy {
                id: confirmBtnFirstRowItem
                visible: !d.compactFooterMode
                Layout.alignment: Qt.AlignRight

                target: confirmButton
            }
        }

        LayoutItemProxy {
            visible: d.compactFooterMode
            Layout.alignment: Qt.AlignLeft

            target: confirmButton
        }

        ConfirmChangePasswordModal {
            id: confirmPasswordChangePopup
            onChangePasswordRequested: {
                root.privacyStore.changePassword(choosePasswordForm.currentPswText, choosePasswordForm.newPswText);
            }

            Connections {
                target: root.privacyStore.privacyModule
                function onPasswordChanged(success: bool, errorMsg: string) {
                    if (success) {
                        confirmPasswordChangePopup.passwordSuccessfulyChanged()
                        keychain.updateCredential(privacyStore.keyUid,
                                                  choosePasswordForm.newPswText)
                        return
                    }

                    choosePasswordForm.reset()
                    choosePasswordForm.errorMsgText = errorMsg
                    confirmPasswordChangePopup.close()
                }
            }
        }
    }

    // Here there are defined the components used inside layout item proxy components:
    StatusButton {
        id: confirmButton
        objectName: "changePasswordModalSubmitButton"
        text: qsTr("Change password")
        enabled: choosePasswordForm.ready
        onClicked: { confirmPasswordChangePopup.open(); }
    }
}
