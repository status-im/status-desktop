import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import "../../shared"

StatusModal {
    property bool pairingPasswordFieldValid: false
    property bool submitted: false

    id: popup
    header.title: qsTr("Insert pairing code")
    anchors.centerIn: parent
    height: 400

    onOpened: {
        submitted = false
        pairingPasswordField.text = "";
        pairingPasswordField.forceActiveFocus(Qt.MouseFocusReason)
    }

    contentItem: Item {
        Input {
            id: pairingPasswordField
            anchors.rightMargin: 56
            anchors.leftMargin: 56
            anchors.top: parent.top
            anchors.topMargin: 88
            anchors.bottomMargin: 0
            placeholderText:  qsTr("Pairing code")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                pairingPasswordFieldValid = pairingPasswordField.text !== "";
            }
        }

        StatusBaseText {
            text: qsTr("Insert the Keycard pairing code")
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
            font.pixelSize: 12
        }
    }

    rightButtons: [
        StatusButton {
            id: submitBtn
            text: qsTr("Pair")
            enabled: pairingPasswordFieldValid

            onClicked: {
                submitted = true
                keycardModel.pair(pairingPasswordField.text)
                popup.close()
            }
        }
    ]
}
