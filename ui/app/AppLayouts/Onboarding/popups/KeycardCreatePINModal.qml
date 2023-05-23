import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0 as Imports

import shared 1.0
import shared.controls 1.0

StatusModal {
    property bool firstPINFieldValid: false
    property bool repeatPINFieldValid: false
    property string pinValidationError: ""
    property string repeatPINValidationError: ""
    property bool submitted: false

    signal submitBtnClicked(string pin)

    id: popup
    headerSettings.title: qsTr("Create PIN")
    anchors.centerIn: parent
    height: 500

    onOpened: {
        submitted = false
        firstPINField.text = "";
        firstPINField.forceActiveFocus(Qt.MouseFocusReason)
    }

    contentItem: Item {
        Input {
            id: firstPINField
            anchors.right: parent.right
            anchors.rightMargin: 56
            anchors.left: parent.left
            anchors.leftMargin: 56
            anchors.top: parent.top
            anchors.topMargin: 88
            placeholderText:  qsTr("New PIN")
            textField.echoMode: TextInput.Password
            onTextChanged: {
                [firstPINFieldValid, pinValidationError] =
                    Imports.Utils.validatePINs("first", firstPINField, repeatPINField);
            }
        }

        Input {
            id: repeatPINField
            enabled: firstPINFieldValid
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.right: firstPINField.right
            anchors.left: firstPINField.left
            anchors.top: firstPINField.bottom
            anchors.topMargin: 32
            placeholderText: qsTr("Confirm PIN")
            textField.echoMode: TextInput.Password
            Keys.onReturnPressed: function(event) {
                if (submitBtn.enabled) {
                    submitBtn.clicked(event)
                }
            }
            onTextChanged: {
                [repeatPINFieldValid, repeatPINValidationError] =
                    Imports.Utils.validatePINs("repeat", firstPINField, repeatPINField);
            }
        }

        StatusBaseText {
            id: validationError
            text: {
                if (pinValidationError !== "") return pinValidationError;
                if (repeatPINValidationError !== "") return repeatPINValidationError;
                return "";
            }
            anchors.top: repeatPINField.bottom
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.left: parent.left
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.dangerColor1
            font.pixelSize: 11
        }

        StatusBaseText {
            text: qsTr("Create a 6 digit long PIN")
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            horizontalAlignment: Text.AlignHCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            color: Theme.palette.directColor1
            font.pixelSize: 12
        }
    }

    rightButtons: [
        StatusButton {
            id: submitBtn
            text: qsTr("Create PIN")
            enabled: firstPINFieldValid && repeatPINFieldValid

            onClicked: {
                submitted = true
                submitBtnClicked()
                popup.close()
            }
        }
    ]
}
