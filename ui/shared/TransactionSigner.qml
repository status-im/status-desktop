import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared/status"

Item {
    id: root
    height: signingPhraseItem.height + signingPhrase.height + txtPassword.height + Style.current.smallPadding + Style.current.bigPadding

    property alias signingPhrase: signingPhrase.text
    property string enteredPassword
    property alias validationError: txtPassword.validationError
    //% "You need to enter a password"
    property string noInputErrorMessage: qsTrId("you-need-to-enter-a-password")
    //% "Password needs to be 6 characters or more"
    property string invalidInputErrorMessage: qsTrId("password-needs-to-be-6-characters-or-more")
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

        StyledText {
            id: labelSigningPhrase
            color: Style.current.secondaryText
            font.pixelSize: 15
            //% "Signing phrase"
            text: qsTrId("signing-phrase")
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
              //% "Signing phrase is a 3 word combination that displayed when you entered the wallet on this device for the first time."
              text: qsTrId("signing-phrase-is-a-3-word-combination-that-displayed-when-you-entered-the-wallet-on-this-device-for-the-first-time-")
            }
        }
    }

    StyledText {
        id: signingPhrase
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: signingPhraseItem.bottom
        anchors.topMargin: Style.current.smallPadding
        font.pixelSize: 15
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
          //% "Enter the password you use to unlock this device"
          text: qsTrId("enter-the-password-you-use-to-unlock-this-device")
        }
    }

    Input {
        id: txtPassword
        anchors.top: signingPhrase.bottom
        anchors.topMargin: Style.current.bigPadding
        focus: true
        customHeight: 56
        //% "Password"
        label: qsTrId("password")
        //% "Enter password"
        placeholderText: qsTrId("enter-password")
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

