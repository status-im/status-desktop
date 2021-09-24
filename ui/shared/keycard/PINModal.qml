import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import StatusQ.Controls 0.1
import "../../imports"
import "../../shared"

ModalPopup {
    property bool pinFieldValid: false

    id: popup
    title: qsTr("Authenticate PIN")
    height: 400

    onOpened: {
        pinField.text = "";
        pinField.forceActiveFocus(Qt.MouseFocusReason)
    }

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
                Utils.validatePINs("first", pinField, pinField);
        }
    }

    StyledText {
        text: qsTr("Insert your 6-digit PIN")
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
            text: qsTr("Authenticate")
            enabled: pinFieldValid

            onClicked: {

            }
        }
    }
}
