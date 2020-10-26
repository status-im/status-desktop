import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
    property bool loading: false
    property string passwordValidationError: ""
    property string repeatPasswordValidationError: ""

    function validate() {
        if (firstPasswordField.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (firstPasswordField.text.length < 4) {
            //% "Password needs to be 4 characters or more"
            passwordValidationError = qsTrId("password-needs-to-be-4-characters-or-more")
        } else {
            passwordValidationError = ""
        }

        if (repeatPasswordField.text === "") {
            //% "You need to repeat your password"
            repeatPasswordValidationError = qsTrId("you-need-to-repeat-your-password")
        } else if (repeatPasswordField.text !== firstPasswordField.text) {
            //% "Both passwords must match"
            repeatPasswordValidationError = qsTrId("both-passwords-must-match")
        } else {
            repeatPasswordValidationError = ""
        }

        return passwordValidationError === "" && repeatPasswordValidationError === ""
    }

    id: popup
    //% "Create a password"
    title: qsTrId("intro-wizard-title-alt4")
    height: 500

    onOpened: {
        firstPasswordField.text = "";
        firstPasswordField.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: firstPasswordField
        anchors.rightMargin: 56
        anchors.leftMargin: 56
        anchors.top: parent.top
        anchors.topMargin: 88
        //% "New password..."
        placeholderText: qsTrId("new-password...")
        textField.echoMode: TextInput.Password
        validationError: popup.passwordValidationError
    }

    Input {
        id: repeatPasswordField
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.right: firstPasswordField.right
        anchors.left: firstPasswordField.left
        anchors.top: firstPasswordField.bottom
        anchors.topMargin: Style.current.xlPadding
        //% "Confirm password…"
        placeholderText: qsTrId("confirm-password…")
        textField.echoMode: TextInput.Password
        validationError: popup.repeatPasswordValidationError
        Keys.onReturnPressed: {
            submitBtn.clicked()
        }
    }

    StyledText {
        //% "At least 6 characters. You will use this password to unlock status on this device & sign transactions."
        text: qsTrId("at-least-6-characters-you-will-use-this-password-to-unlock-status-on-this-device-sign-transactions.")
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
        horizontalAlignment: Text.AlignHCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: Style.current.secondaryText
        font.pixelSize: 12
    }

    footer: Item {
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.bottom: popup.bottom
        anchors.left: parent.left

        StatusButton {
            id: submitBtn
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            state: loading ? "pending" : "default"
            //% "Create password"
            text: qsTrId("create-password")

            enabled: firstPasswordField.text !== "" && repeatPasswordField.text !== "" && !loading

            MessageDialog {
                id: importError
                //% "Error importing account"
                title: qsTrId("error-importing-account")
                //% "An error occurred while importing your account: "
                text: qsTrId("an-error-occurred-while-importing-your-account:-")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
                onVisibilityChanged: {
                    loading = false
                }
            }

            MessageDialog {
                id: importLoginError
                //% "Login failed"
                title: qsTrId("login-failed")
                //% "Login failed. Please re-enter your password and try again."
                text: qsTrId("login-failed.-please-re-enter-your-password-and-try-again.")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
                onVisibilityChanged: {
                    loading = false
                }
            }

            Connections {
                target: onboardingModel
                ignoreUnknownSignals: true
                onLoginResponseChanged: {
                    if (error) {
                        errorSound.play()
                        loading = false
                        importLoginError.open()
                    }
                }
            }

            onClicked: {
                if (!validate()) {
                    errorSound.play()
                    return
                }
                loading = true
                loginModel.isCurrentFlow = false;
                onboardingModel.isCurrentFlow = true;
                const result = onboardingModel.storeDerivedAndLogin(repeatPasswordField.text);
                const error = JSON.parse(result).error
                if (error) {
                    errorSound.play()
                    importError.text += error
                    return importError.open()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
