import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared 1.0
import shared.controls 1.0
import utils 1.0 as Imports

StatusModal {
    property bool pinFieldValid: false
    property bool submitted: false

    id: popup
    header.title: qsTr("Authenticate PIN")
    anchors.centerIn: parent
    height: 400

    onOpened: {
        submitted = false
        pinField.text = "";
        pinField.forceActiveFocus(Qt.MouseFocusReason)
    }

    contentItem: Item {
        Input {
            id: pinField
            anchors.rightMargin: 56
            anchors.leftMargin: 56
            anchors.top: parent.top
            anchors.topMargin: 88
            placeholderText:  qsTr("PIN")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                [pinFieldValid, _] =
                    Imports.Utils.validatePINs("first", pinField, pinField);
            }
        }

        StatusBaseText {
            text: qsTr("Insert your 6-digit PIN")
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
            text: qsTr("Authenticate")
            enabled: pinFieldValid

            onClicked: {
                submitted = true
                // Not Refactored Yet
//                keycardModel.authenticate(pinField.text)
                popup.close()
            }
        }
    ]

}
