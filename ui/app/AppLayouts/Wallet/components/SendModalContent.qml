import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: sendModalContent
    property alias amountInput: txtAmount
    property alias amountText: txtAmount.text
    property alias toText: txtTo.text
    property alias passwordText: txtPassword.text
    property var accounts
    property string defaultAccount: "0x1234"
    property string selectedAccount: accounts[0].name
    property string selectedFromAccountAddress: defaultAccount

    anchors.left: parent.left
    anchors.right: parent.right

    Input {
        id: txtAmount
        label: qsTr("Amount")
        icon: "../../../img/token-icons/eth.svg"
        anchors.top: parent.top
        placeholderText: qsTr("Enter ETH")
    }


    Select {
        id: txtFrom
        label: qsTr("From account")
        anchors.top: txtAmount.bottom
        anchors.topMargin: Theme.padding
        selectedText: sendModalContent.selectedAccount
        selectOptions: sendModalContent.accounts.map(function (account) {
            return {
                text: account.name,
                onClicked: function () {
                    selectedAccount = account.name
                    selectedFromAccountAddress = account.address
                }
            }
        })
    }

    Input {
        id: txtTo
        label: qsTr("Recipient")
        text: defaultAccount
        placeholderText: qsTr("Send to")
        anchors.top: txtFrom.bottom
        anchors.topMargin: Theme.padding
    }

    Input {
        id: txtPassword
        label: qsTr("Password")
        placeholderText: qsTr("Enter Password")
        anchors.top: txtTo.bottom
        anchors.topMargin: Theme.padding
        textField.echoMode: TextInput.Password
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.75;height:480;width:640}
}
##^##*/
