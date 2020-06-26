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
    property int selectedAccountIndex: 0
    property string selectedAccountAddress: accounts[selectedAccountIndex].address

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
        iconHeight: 12
        iconWidth: 12
        icon: "../../../img/walletIcon.svg"
        iconColor: accounts[selectedAccountIndex].iconColor
        label: qsTr("From account")
        anchors.top: txtAmount.bottom
        anchors.topMargin: Theme.padding
        selectedText: accounts[selectedAccountIndex].name
        selectOptions: sendModalContent.accounts.map(function (account, index) {
            return {
                text: account.name,
                onClicked: function () {
                    selectedAccountIndex = index
                }
            }
        })
    }

    StyledText {
        id: textSelectAccountAddress
        text: accounts[selectedAccountIndex].address
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: 2
        elide: Text.ElideMiddle
        anchors.top: txtFrom.bottom
        font.pixelSize: 12
        color: Theme.darkGrey
    }

    Input {
        id: txtTo
        label: qsTr("Recipient")
        text: defaultAccount
        placeholderText: qsTr("Send to")
        anchors.top: textSelectAccountAddress.bottom
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
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
