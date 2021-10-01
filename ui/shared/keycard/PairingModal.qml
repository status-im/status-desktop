import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import StatusQ.Controls 0.1
import "../../imports"
import "../../shared"

ModalPopup {
    property bool pairingPasswordFieldValid: false
    property bool submitted: false

    id: popup
    title: qsTr("Insert pairing code")
    height: 400

    onOpened: {
        submitted = false
        pairingPasswordField.text = "";
        pairingPasswordField.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: pairingPasswordField
        anchors.rightMargin: 56
        anchors.leftMargin: 56
        anchors.top: parent.top
        anchors.topMargin: 88
        placeholderText:  qsTr("Pairing code")
        textField.echoMode: TextInput.Password
        onTextChanged: {
          pairingPasswordFieldValid = pairingPasswordField.text !== "";
        }
    }

    StyledText {
        text: qsTr("Insert the Keycard pairing code")
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
        width: parent.width
        height: submitBtn.height

        StatusButton {
            id: submitBtn
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            text: qsTr("Pair")
            enabled: pairingPasswordFieldValid

            onClicked: {
                submitted = true
                keycardModel.pair(pairingPasswordField.text)
                popup.close()
            }
        }
    }
}
