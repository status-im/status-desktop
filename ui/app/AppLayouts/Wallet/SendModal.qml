import QtQuick 2.13
import QtQuick.Controls 2.13
//import QtQuick.Layouts 1.13
//import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "./components"

ModalPopup {
    id: popup

    title: qsTr("Send")

    onOpened: {
        sendModalContent.amountInput.text = ""
        sendModalContent.amountInput.forceActiveFocus(Qt.MouseFocusReason)
        sendModalContent.defaultAccount = walletModel.getDefaultAccount()
        const accounts = walletModel.accounts
        const numAccounts = accounts.rowCount()
        const accountsData = []
        for (let i = 0; i < numAccounts; i++) {
            accountsData.push({
                name: accounts.rowData(i, 'name'),
                address: accounts.rowData(i, 'address'),
                iconColor: accounts.rowData(i, 'iconColor')
            })
        }
        sendModalContent.accounts = accountsData
    }

    SendModalContent {
        id: sendModalContent
        accounts: []
    }

    footer: StyledButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: qsTr("Send")

        onClicked: {
            if (!sendModalContent.validate()) {
                return;
            }

            let result = walletModel.onSendTransaction(sendModalContent.selectedAccountAddress,
                                                       sendModalContent.toText,
                                                       sendModalContent.amountText,
                                                       sendModalContent.passwordText)
            console.log(result)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

