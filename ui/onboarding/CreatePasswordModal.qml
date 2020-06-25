import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../imports"
import "../shared"

ModalPopup {
    property bool loading: false
    property string passwordValidationError: ""
    property string repeatPasswordValidationError: ""

    function validate() {
        if (firstPasswordField.text === "") {
            passwordValidationError = qsTr("You need to enter a password")
        } else if (firstPasswordField.text.length < 4) {
            passwordValidationError = qsTr("Password needs to be 4 characters or more")
        } else {
            passwordValidationError = ""
        }

        if (repeatPasswordField.text === "") {
            repeatPasswordValidationError = qsTr("You need to repeat your password")
        } else if (repeatPasswordField.text !== firstPasswordField.text) {
            repeatPasswordValidationError = qsTr("Both passwords must match")
        } else {
            repeatPasswordValidationError = ""
        }

        return passwordValidationError === "" && repeatPasswordValidationError === ""
    }

    id: popup
    title: qsTr("Create a password")
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
        placeholderText: qsTr("New password...")
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
        anchors.topMargin: Theme.xlPadding
        placeholderText: qsTr("Confirm password…")
        textField.echoMode: TextInput.Password
        validationError: popup.repeatPasswordValidationError
        Keys.onReturnPressed: {
            submitBtn.clicked()
        }
    }

    StyledText {
        text: qsTr("At least 6 characters. You will use this password to unlock status on this device & sign transactions.")
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Theme.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Theme.xlPadding
        horizontalAlignment: Text.AlignHCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: Theme.darkGrey
        font.pixelSize: 12
    }

    footer: Item {
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.bottom: popup.bottom
        anchors.left: parent.left

        Image {
            id: loadingImg
            visible: loading
            anchors.top: submitBtn.top
            anchors.topMargin: Theme.padding
            anchors.right: submitBtn.left
            anchors.rightMargin: Theme.padding
            source: "../app/img/settings.svg"
            width: 20
            height: 20
            fillMode: Image.Stretch
            RotationAnimator {
                target: loadingImg;
                from: 0;
                to: 360;
                duration: 1200
                running: true
                loops: Animation.Infinite
            }
        }

        StyledButton {
            id: submitBtn
            anchors.bottom: parent.bottom
            anchors.topMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            label: loading ? qsTr("Logging in...") : qsTr("Create password")

            disabled: firstPasswordField.text === "" || repeatPasswordField.text === "" || loading

            MessageDialog {
                id: importError
                title: qsTr("Error importing account")
                text: qsTr("An error occurred while importing your account: ")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
                onVisibilityChanged: {
                    loading = false
                }
            }

            MessageDialog {
                id: importLoginError
                title: qsTr("Login failed")
                text: qsTr("Login failed. Please re-enter your password and try again.")
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
                        loading = false
                        importLoginError.open()
                    }
                }
            }

            onClicked: {
                if (!validate()) {
                    return
                }
                // TODO this doesn't seem to work because the function freezes the view
                loading = true
                const result = onboardingModel.storeDerivedAndLogin(repeatPasswordField.text);
                const error = JSON.parse(result).error
                if (error) {
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
