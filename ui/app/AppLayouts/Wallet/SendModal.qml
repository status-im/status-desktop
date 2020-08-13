import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "./components"

ModalPopup {
    id: popup

    //% "Send"
    title: qsTrId("command-button-send")
    height: 700

    onOpened: {
        sendModalContent.amountInput.selectedAmount = ""
        sendModalContent.passwordInput.text = ""
        sendModalContent.amountInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    SendModalContent {
        id: sendModalContent
        closePopup: function () {
            popup.close()
        }
    }

    footer: Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        StyledButton {
            id: btnBack
            anchors.left: parent.left
            label: qsTr("Back")
            visible: !btnPreview.visible
            onClicked: {
                btnPreview.visible = true
                sendModalContent.showInputs()
            }
        }
        StyledButton {
            id: btnPreview
            anchors.right: parent.right
            label: qsTr("Preview")
            onClicked: {
                if (!sendModalContent.validate()) {
                    return
                }
                visible = false
                sendModalContent.showPreview()
            }
        }
        StyledButton {
            id: btnSend
            anchors.right: parent.right
            visible: !btnPreview.visible
            //% "Send"
            label: qsTrId("command-button-send")
            onClicked: {
                sendModalContent.send()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

