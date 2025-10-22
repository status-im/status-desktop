import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Controls

import utils

import "../status"
import "../panels"
import "../controls"

Item {
    id: root
    height: signingPhraseItem.height + signingPhrase.height + txtPassword.height + Theme.smallPadding + Theme.bigPadding

    property alias signingPhrase: signingPhrase.text
    property string enteredPassword
    property alias validationError: txtPassword.validationError
    property string noInputErrorMessage: qsTr("You need to enter a password")
    property string invalidInputErrorMessage: qsTr("Password needs to be 6 characters or more")
    property bool isValid: false

    function forceActiveFocus(reason) {
        txtPassword.forceActiveFocus(reason)
    }

    function validate() {
        txtPassword.validationError = ""
        const noInput = txtPassword.text === ""
        if (noInput) {
            txtPassword.validationError = noInputErrorMessage
        } else if (txtPassword.text.length < 6) {
            txtPassword.validationError = invalidInputErrorMessage
        }
        isValid = txtPassword.validationError === ""
        return isValid
    }

    Item {
        id: signingPhraseItem
        anchors.horizontalCenter: parent.horizontalCenter
        height: labelSigningPhrase.height
        width: labelSigningPhrase.width + infoButton.width + infoButton.anchors.leftMargin

        StatusBaseText {
            id: labelSigningPhrase
            color: Theme.palette.secondaryText
            text: qsTr("Signing phrase")
        }

        StatusRoundButton {
            id: infoButton
            anchors.left: labelSigningPhrase.right
            anchors.leftMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            width: 13
            height: 13
            icon.width: width
            icon.height: height
            icon.name: "info"
            StatusToolTip {
                visible: infoButton.hovered
                text: qsTr("Signing phrase is a 3 word combination that is displayed when you entered the wallet on this device for the first time.")
            }
        }
    }

    StatusBaseText {
        id: signingPhrase
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: signingPhraseItem.bottom
        anchors.topMargin: Theme.smallPadding
        text: root.signingPhrase
    }

    StatusRoundButton {
        id: passwordInfoButton
        anchors.left: parent.left
        anchors.leftMargin: 67
        anchors.top: txtPassword.top
        anchors.topMargin: 2
        width: 13
        height: 13
        icon.width: width
        icon.height: height
        icon.name: "info"
        StatusToolTip {
            visible: passwordInfoButton.hovered
            text: qsTr("Enter the password you use to unlock this device")
        }
    }

    Input {
        id: txtPassword
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: signingPhrase.bottom
        anchors.topMargin: Theme.bigPadding
        textField.objectName: "transactionSignerPasswordInput"
        focus: !SQUtils.Utils.isMobile
        customHeight: 56
        label: qsTr("Password")
        placeholderText: qsTr("Enter password")
        textField.echoMode: TextInput.Password
        validationErrorAlignment: TextEdit.AlignRight
        validationErrorTopMargin: 8
        onTextChanged: {
            if(root.validate()) {
                root.enteredPassword = this.text
            }
        }
    }
}
