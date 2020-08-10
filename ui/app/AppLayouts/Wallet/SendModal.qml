import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../imports"
import "../../../shared"
import "./components"

ModalPopup {
    id: popup

    //% "Send"
    title: qsTrId("command-button-send")
    height: 600

    onOpened: {
        sendModalContent.amountInput.text = ""
        sendModalContent.passwordInput.text = ""
        sendModalContent.amountInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    SendModalContent {
        id: sendModalContent
        closePopup: function () {
            popup.close()
        }
    }

    footer: StyledButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        //% "Send"
        label: qsTrId("command-button-send")

        onClicked: {
            sendModalContent.send()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

