import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"

Item {
    id: root
    height: signingPhraseItem.height + signingPhrase.height + txtPassword.height + Style.current.smallPadding + Style.current.bigPadding

    property string signingPhrase: "not a real one"
    property alias passwordInput: txtPassword
    property string validationError: ""
  
    Item {
        id: signingPhraseItem
        anchors.horizontalCenter: parent.horizontalCenter
        height: labelSigningPhrase.height 
        width: labelSigningPhrase.width + infoButton.width + infoButton.anchors.leftMargin

        StyledText {
            id: labelSigningPhrase
            color: Style.current.secondaryText
            font.pixelSize: 15
            text: qsTr("Signing phrase")
        }

        IconButton {
            id: infoButton
            clickable: false
            anchors.left: labelSigningPhrase.right
            anchors.leftMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            width: 13
            height: 13
            iconName: "info"
            color: Style.current.lightBlue
            StatusToolTip {
              visible: infoButton.hovered
              width: 337
              text: qsTr("Signing phrase is a 3 word combination that displayed when you entered the wallet on this device for the first time.")
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

    IconButton {
        id: passwordInfoButton
        clickable: false
        anchors.left: parent.left
        anchors.leftMargin: 67
        anchors.top: txtPassword.top
        anchors.topMargin: 2
        width: 13
        height: 13
        iconName: "info"
        color: Style.current.lightBlue
        StatusToolTip {
          visible: passwordInfoButton.hovered
          width: 224
          text: qsTr("Enter the password you use to unlock this device")
        }
    }

    Input {
        anchors.top: signingPhrase.bottom
        anchors.topMargin: Style.current.bigPadding
        id: txtPassword
        //% "Password"
        label: qsTrId("password")
        //% "Enter Password"
        placeholderText: qsTrId("enter-password")
        textField.echoMode: TextInput.Password
        validationError: root.validationError
    }
}

