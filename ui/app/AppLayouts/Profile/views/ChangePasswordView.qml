import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQml.Models 2.14

import shared.panels 1.0
import shared.controls 1.0
import shared.stores 1.0
import shared.views 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Profile.popups 1.0

SettingsContentBase {
    id: root

    property var privacyStore

    readonly property bool biometricsEnabled: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store

    readonly property Connections privacyStoreConnections: Connections {
        target: Qt.platform.os === Constants.mac ? root.privacyStore.privacyModule : null

        function onStoreToKeychainError(errorDescription: string) {
            biometricsSwitch.checked = Qt.binding(() => { return biometricsSwitch.currentStoredValue })
        }

        function onStoreToKeychainSuccess() {
            biometricsSwitch.checked = Qt.binding(() => { return biometricsSwitch.currentStoredValue })
        }
    }

    property var passwordStrengthScoreFunction: function () {}

    titleRowComponentLoader.sourceComponent: Item {
        implicitWidth: 226
        implicitHeight: 38
        visible: (Qt.platform.os === Constants.mac)
        StatusSwitch {
            id: biometricsSwitch
            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true
            text: qsTr("Enable biometrics")
            checked: root.biometricsEnabled
            onToggled: {
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
                    anchors.margins: Style.current.padding
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
                            if (biometricsSwitch.checked && !biometricsSwitch.biometricsEnabled) {
                                root.privacyStore.tryStoreToKeyChain();
                            } else if (!biometricsSwitch.checked) {
                                root.privacyStore.tryRemoveFromKeyChain();
                            }
                        }
                    }
                }
            }
            onClosed: {
                biometricsSwitch.checked = Qt.binding(() => { return root.biometricsEnabled });
            }
        }
    }


    ColumnLayout {
        PasswordView {
            id: choosePasswordForm

            width: 507
            height: 660

            createNewPsw: false
            title: qsTr("Change your password.")
            titleSize: 17
            contentAlignment: Qt.AlignLeft

            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction
            onReadyChanged: {
                submitBtn.enabled = ready
            }

            onReturnPressed: {
                if (ready) {
                    confirmPasswordChangePopup.open();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            StatusLinkText {
                text: qsTr("Clear & cancel")
                onClicked: {
                    choosePasswordForm.reset();
                }
            }
            Item { Layout.fillWidth: true }
            StatusButton {
                id: submitBtn
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
