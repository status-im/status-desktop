import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import shared.panels 1.0
import shared.controls 1.0
import shared.stores 1.0
import shared.views 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Profile.popups 1.0

SettingsContentBase {
    id: root

    property var privacyStore
    property var passwordStrengthScoreFunction: function () {}

    //TODO https://github.com/status-im/status-desktop/issues/13302
//    titleRowComponentLoader.sourceComponent: Item {
//        implicitWidth: 226
//        implicitHeight: 38
//        StatusSwitch {
//            LayoutMirroring.enabled: true
//            text: qsTr("Enable biometrics")
//            onToggled: {
//                //
//            }
//        }
//    }


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
