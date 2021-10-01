import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import StatusQ.Controls 0.1
import "../../imports"
import "../../shared"
import "../../shared/keycard"

ModalPopup {
    property bool firstPINFieldValid: false
    property bool repeatPINFieldValid: false
    property string pinValidationError: ""
    property string repeatPINValidationError: ""
    property bool submitted: false

    id: popup
    title: qsTr("Create PIN")
    height: 500

    onOpened: {
        submitted = false
        firstPINField.text = "";
        firstPINField.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: firstPINField
        anchors.rightMargin: 56
        anchors.leftMargin: 56
        anchors.top: parent.top
        anchors.topMargin: 88
        placeholderText:  qsTr("New PIN")
        textField.echoMode: TextInput.Password
        onTextChanged: {
            [firstPINFieldValid, pinValidationError] =
                Utils.validatePINs("first", firstPINField, repeatPINField);
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
        anchors.topMargin: Style.current.xlPadding
        placeholderText: qsTr("Confirm PIN")
        textField.echoMode: TextInput.Password
        Keys.onReturnPressed: function(event) {
            if (submitBtn.enabled) {
                submitBtn.clicked(event)
            }
        }
        onTextChanged: {
            [repeatPINFieldValid, repeatPINValidationError] =
                Utils.validatePINs("repeat", firstPINField, repeatPINField);
        }
    }

    StyledText {
        id: validationError
        text: {
            if (pinValidationError !== "") return pinValidationError;
            if (repeatPINValidationError !== "") return repeatPINValidationError;
            return "";
        }
        anchors.top: repeatPINField.bottom
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
        horizontalAlignment: Text.AlignHCenter
        color: Style.current.danger
        font.pixelSize: 11
    }

    StyledText {
        text: qsTr("Create a 6 digit long PIN")
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
            text: qsTr("Create PIN")
            enabled: firstPINFieldValid && repeatPINFieldValid

            onClicked: {
                submitted = true
                keycardModel.init(firstPINField.text)
                popup.close()
            }
        }
    }
}
