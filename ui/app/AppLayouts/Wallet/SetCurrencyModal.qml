import QtQuick 2.13
import QtQuick.Controls 2.13
//import QtQuick.Layouts 1.13
//import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "./components"

Item {
    function open() {
        popup.open()
        setCurrencyModalContent.currency = walletModel.defaultCurrency
    }

    function close() {
        popup.close()
    }

    ModalPopup {
        id: popup
        width: 480
        height: 510

        title: qsTr("Settings")

        SetCurrencyModalContent {
            id: setCurrencyModalContent
        }

        footer: StyledButton {
            anchors.right: parent.right
            label: qsTr("Save")
            onClicked: {
                console.log("TODO: apply all accounts")
                popup.close()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
