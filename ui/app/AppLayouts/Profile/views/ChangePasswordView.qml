import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import shared.panels 1.0
import shared.controls 1.0
import shared.stores 1.0
import shared.views 1.0
import utils 1.0

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Profile.popups 1.0
import AppLayouts.Profile.stores 1.0

SettingsContentBase {
    id: root

    property PrivacyStore privacyStore
    required property Keychain keychain

    QtObject {
        id: d

        property int reevaluateTrigger
        function reevaluateHasCredential() {
            reevaluateTrigger++
        }

        readonly property bool biometricsEnabled: {
            reevaluateTrigger // Reference for binding
            return keychain.hasCredential(privacyStore.keyUid) === Keychain.StatusSuccess
        }
    }

    readonly property Item biometricsPopup: titleRowComponentLoader.item
    readonly property Connections privacyStoreConnections: Connections {
        target: root.privacyStore.privacyModule

        function onSaveBiometricsRequested(keyUid, credential) {
            biometricsPopup.popupItem.close()
            const status = keychain.saveCredential(keyUid, credential)

            switch (status) {
            case Keychain.StatusSuccess:
                Global.displayToastMessage(
                            qsTr("Biometric login and transaction authentication enabled for this device"),
                            "", "checkmark-circle", false, Constants.ephemeralNotificationType.success, "")
                break
            default:
                Global.displayToastMessage(
                            qsTr("Failed to enable biometric login and transaction authentication for this device"),
                            "", "warning", false, Constants.ephemeralNotificationType.danger, "")
            }

            d.reevaluateHasCredential()
        }
    }

    property var passwordStrengthScoreFunction: function () {}

    titleRowComponentLoader.sourceComponent: Item {
        implicitWidth: 226
        implicitHeight: 38
        visible: (Qt.platform.os === Constants.mac)

        property StatusSwitch switchItem: biometricsSwitch
        property StatusDialog popupItem: enableBiometricsPopup

        StatusSwitch {
            id: biometricsSwitch

            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true

            text: qsTr("Enable biometrics")
            textColor: Theme.palette.baseColor1

            visible: root.keychain.available

            checked: root.keychain.available && d.biometricsEnabled
            onReleased: {
                enableBiometricsPopup.open();
            }
            StatusToolTip {
                x: 15
                visible: (!root.checked && biometricsSwitch.hovered)
                text: qsTr("Biometric login and transaction authentication")
            }
        }
        StatusDialog {
            id: enableBiometricsPopup
            width: 480
            title: biometricsSwitch.checked ? qsTr("Enable biometrics") : qsTr("Disable biometrics")

            StatusBaseText {
                anchors.fill: parent
                anchors.margins: Theme.padding
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                text: biometricsSwitch.checked ? qsTr("Do you want to enable biometrics for login and transaction authentication?") :
                                                 qsTr("Are you sure you want to disable biometrics for login and transaction authentication?")
            }

            footer: StatusDialogFooter {
                rightButtons: ObjectModel {
                    StatusFlatButton {
                        text: qsTr("Cancel")
                        onClicked: {
                            enableBiometricsPopup.close();
                        }
                    }
                    StatusButton {
                        text: biometricsSwitch.checked ? qsTr("Yes, enable biometrics") : qsTr("Yes, disable biometrics")
                        onClicked: {
                            if (biometricsSwitch.checked) {
                                root.privacyStore.tryStoreToKeyChain()
                                return
                            }

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
                                            "", "warning", false, Constants.ephemeralNotificationType.danger, "")
                            }

                            enableBiometricsPopup.close()
                        }
                    }
                }
            }

            onClosed: {
                biometricsSwitch.checked = Qt.binding(() => { return d.biometricsEnabled });
                d.reevaluateHasCredential()
            }
        }
    }


    ColumnLayout {
        PasswordView {
            id: choosePasswordForm

            width: 507
            height: 660

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
                text: qsTr("Clear & cancel")
                onClicked: choosePasswordForm.reset()
            }
            Item { Layout.fillWidth: true }
            StatusButton {
                Layout.alignment: Qt.AlignRight
                objectName: "changePasswordModalSubmitButton"
                text: qsTr("Change password")
                enabled: choosePasswordForm.ready
                onClicked: { confirmPasswordChangePopup.open(); }
            }
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
}
