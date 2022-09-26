import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property var privacyStore
    property bool loading: false
    property bool firstPasswordFieldValid: false
    property bool repeatPasswordFieldValid: false
    property string passwordValidationError: ""
    property string repeatPasswordValidationError: ""

    signal offerToStorePassword(string password, bool runStoreToKeychainPopup)

    id: popup
    title: qsTr("Store password")
    height: 500

    onOpened: {
        if (userProfile.isKeycardUser) {
            firstPinInputField.statesInitialization()
            firstPinInputField.forceFocus()
        }
        else {
            firstPasswordField.text = "";
            firstPasswordField.forceActiveFocus(Qt.MouseFocusReason)
        }
    }

    Column {
        anchors.fill: parent
        leftPadding: d.padding
        rightPadding: d.padding
        topPadding: Style.current.xlPadding
        bottomPadding: Style.current.xlPadding
        spacing: Style.current.xlPadding

        QtObject {
            id: d

            readonly property int padding: 56
            readonly property int fontSize: 15
        }

        Input {
            id: firstPasswordField
            width: parent.width - 2 * d.padding
            visible: !userProfile.isKeycardUser
            placeholderText: qsTr("Current password...")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                [firstPasswordFieldValid, passwordValidationError] =
                                                                   Utils.validatePasswords("first", firstPasswordField, repeatPasswordField);
                [repeatPasswordFieldValid, repeatPasswordValidationError] =
                                                                          Utils.validatePasswords("repeat", firstPasswordField, repeatPasswordField);
            }
        }

        Input {
            id: repeatPasswordField
            visible: !userProfile.isKeycardUser
            width: parent.width - 2 * d.padding
            enabled: firstPasswordFieldValid
            placeholderText: qsTr("Confirm password…")
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
            anchors.horizontalCenter: parent.horizontalCenter
            visible: userProfile.isKeycardUser
            text: qsTr("Enter new PIN")
            font.pixelSize: d.fontSize
        }

        StatusPinInput {
            id: firstPinInputField
            anchors.horizontalCenter: parent.horizontalCenter
            visible: userProfile.isKeycardUser
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength

            onPinInputChanged: {
                if (pinInput.length == Constants.keycard.general.keycardPinLength) {
                    repeatPinInputField.statesInitialization()
                    repeatPinInputField.forceFocus()
                }

                [firstPasswordFieldValid, passwordValidationError] =
                                                                   Utils.validatePINs("first", firstPinInputField, repeatPinInputField);
                [repeatPasswordFieldValid, repeatPasswordValidationError] =
                                                                          Utils.validatePINs("repeat", firstPinInputField, repeatPinInputField);
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: userProfile.isKeycardUser
            text: qsTr("Repeat PIN")
            font.pixelSize: d.fontSize
        }

        StatusPinInput {
            id: repeatPinInputField
            anchors.horizontalCenter: parent.horizontalCenter
            visible: userProfile.isKeycardUser
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength

            onPinInputChanged: {
                [repeatPasswordFieldValid, repeatPasswordValidationError] =
                                                                          Utils.validatePINs("repeat", firstPinInputField, repeatPinInputField);
            }
        }


        StyledText {
            id: validationError
            text: {
                if (passwordValidationError !== "") return passwordValidationError;
                if (repeatPasswordValidationError !== "") return repeatPasswordValidationError;
                return "";
            }
            anchors.horizontalCenter: parent.horizontalCenter
            color: Style.current.danger
            font.pixelSize: 11
        }
    }

    footer: Item {
        width: parent.width
        height: submitBtn.height

        StatusButton {
            id: submitBtn
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            state: loading ? "pending" : "default"

            text: userProfile.isKeycardUser? qsTr("Store PIN") : qsTr("Store password")

            enabled: firstPasswordFieldValid && repeatPasswordFieldValid && !loading

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

            onClicked: {
                if (!userProfile.isKeycardUser) {
                    // validate the entered password
                    var validatePassword = privacyStore.validatePassword(repeatPasswordField.text)
                    if(!validatePassword) {
                        firstPasswordFieldValid = false
                        passwordValidationError = qsTr("Incorrect password")
                    }
                    else {
                        popup.offerToStorePassword(repeatPasswordField.text, true)
                        popup.close()
                    }
                }
                else {
                    popup.offerToStorePassword(repeatPinInputField.pinInput, true)
                    popup.close()
                }
            }
        }
    }
}
