import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import StatusQ.Controls 0.1
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    title: qsTr("Change password")
    height: 510

    onOpened: {
        reset()
    }

    property bool loading: false
    property bool firstPasswordFieldValid: false
    property bool repeatPasswordFieldValid: false
    property string passwordValidationError: ""
    property string repeatPasswordValidationError: ""
    property string changePasswordError: ""

    function reset() {
        currentPasswordField.text = ""
        firstPasswordField.text = ""
        repeatPasswordField.text = ""
        currentPasswordField.forceActiveFocus(Qt.MouseFocusReason)

        firstPasswordFieldValid = false
        repeatPasswordFieldValid = false
        passwordValidationError = ""
        repeatPasswordValidationError = ""
        changePasswordError = ""
        loading = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: Style.current.xlPadding

        Input {
            id: currentPasswordField
            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            placeholderText: qsTr("Current password")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                changePasswordError = ""
            }
        }

        Input {
            id: firstPasswordField
            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            //% "New password..."
            placeholderText: qsTrId("new-password...")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                [firstPasswordFieldValid, passwordValidationError] =
                    Utils.validatePasswords("first", firstPasswordField, repeatPasswordField);
            }
        }

        Input {
            id: repeatPasswordField
            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            enabled: firstPasswordFieldValid
            //% "Confirm password…"
            placeholderText: qsTrId("confirm-password…")
            textField.echoMode: TextInput.Password
            Keys.onReturnPressed: function(event) {
                if (submitBtn.enabled) {
                    submitBtn.clicked(event)
                }
            }
            onTextChanged: {
                [repeatPasswordFieldValid, repeatPasswordValidationError] =
                    Utils.validatePasswords("repeat", firstPasswordField, repeatPasswordField);
            }
        }

        StyledText {
            id: validationError
            text: passwordValidationError || repeatPasswordValidationError || changePasswordError
            Layout.preferredWidth: 340
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            color: Style.current.danger
            font.pixelSize: 12
        }

        StyledText {
            text: qsTr("Status app will be terminated after password change. You need to restart it to login using the new password.")
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 340
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            color: Style.current.secondaryText
            font.pixelSize: 12
        }
    }

    footer: Item {
        width: parent.width
        height: submitBtn.height

        StatusButton {
            id: submitBtn
            anchors.right: parent.right
            text: qsTr("Change password")
            enabled: popup.firstPasswordFieldValid && popup.repeatPasswordFieldValid && !popup.loading
            state: popup.loading ? "pending" : "default"

            onClicked: {
                popup.loading = true
                Qt.callLater(function() {
                    if (profileModel.changePassword(currentPasswordField.text, firstPasswordField.text)) {
                        popup.close()
                    } else {
                        reset()
                        changePasswordError = qsTr("Failed to change password.")
                    }
                })
            }
        }
    }
}
