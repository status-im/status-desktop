import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12


import utils 1.0
import "../../../../shared"
import "../../../../shared/panels"
import "../../../../shared/controls"

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: popup
    width: 480
    height: 510
    closePolicy: Popup.NoAutoClose
    header.title: qsTr("Change password")

    onOpened: {
        reset();
    }

    property var successPopup
    property string indicationText: ""
    property bool passwordInputValid
    property bool currPasswordInputValid
    property string currPasswordValidationError: ""

    function reset() {
        passwordInput.text = "";
        currentPasswordInput.text = "";
        currentPasswordInput.forceActiveFocus(Qt.MouseFocusReason);
        popup.indicationText = "At least 6 characters. Your password protects your keys. You need it to unlock Status and transact.";
        popup.currPasswordValidationError = "";
        passwordInput.validationError = "";
        popup.passwordInputValid = false;
        popup.currPasswordInputValid = false;
    }

    contentItem: ColumnLayout {
        id: contentItem
        anchors.fill: parent
        anchors {
            topMargin: (Style.current.xlPadding + popup.topPadding)
            leftMargin: Style.current.xlPadding
            rightMargin: Style.current.xlPadding
            bottomMargin: (Style.current.xlPadding + popup.bottomPadding)
        }
        spacing: Style.current.padding

        //TODO replace with StatusInput as soon as it supports password
        Input {
            id: currentPasswordInput
            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            placeholderText: ""
            label: qsTr("Current password")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                popup.currPasswordInputValid = (currentPasswordInput.text.length >= 6);
            }
        }

        //TODO replace with StatusInput as soon as it supports password
        Input {
            id: passwordInput
            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            placeholderText: ""
            label: qsTrId("new-password...")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                popup.passwordInputValid = ((passwordInput.text !== "") && (passwordInput.text.length >= 6));
                //setting validationError so that input becomes red
                passwordInput.validationError = (!popup.passwordInputValid) ? " " : "";
                popup.indicationText = (!popup.passwordInputValid ? "<font color=\"#FF2D55\">" : "")
                    + "At least 6 characters." + (!popup.passwordInputValid ? "</font>" : "")
                    + "Your password protects your keys. You need it to unlock Status and transact."
            }
        }

        Item {
            Layout.fillHeight: true
        }

        StyledText {
            id: validationError
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            visible: (text !== "")
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Style.current.danger
            text: popup.currPasswordValidationError
        }

        StyledText {
            text: qsTr(indicationText)
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 340
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            color: Style.current.secondaryText
            font.pixelSize: Style.current.tertiaryTextFontSize
        }
    }

    rightButtons: [
        StatusButton {
            id: submitBtn
            text: qsTr("Change password")
            enabled: (popup.passwordInputValid && popup.currPasswordInputValid && !submitBtn.loading)

            property Timer sim: Timer {
                id: pause
                interval: 20
                onTriggered: {
                    submitBtn.changePasswordBegin();
                }
            }

            onClicked: {
                submitBtn.loading = true;
                //changePassword operation blocks the UI so loading = true; will never
                //have any affect until changePassword is done. Getting around it with a
                //small pause (timer) in order to get the desired behavior
                pause.start();
            }

            function changePasswordBegin() {
                if (privacyModule.changePassword(currentPasswordInput.text, passwordInput.text)) {
                    popup.successPopup.open();
                    submitBtn.enabled = false;
                } else {
                    reset();
                    passwordInput.validationError = " ";
                    popup.currPasswordValidationError = qsTr("Incorrect password");
                }
                submitBtn.loading = false;
            }
        }
    ]
}
