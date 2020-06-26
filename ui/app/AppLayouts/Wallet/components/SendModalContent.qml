import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: sendModalContent
    property alias amountInput: txtAmount
    property alias amountText: txtAmount.text
    property alias fromText: txtFrom.text
    property alias toText: txtTo.text
    property alias passwordText: txtPassword.text
    property string defaultAccount: "0x1234"

    anchors.left: parent.left
    anchors.right: parent.right

    Input {
        id: txtAmount
        label: qsTr("Amount")
        icon: "../../../img/token-icons/eth.svg"
        anchors.top: parent.top
        placeholderText: qsTr("Enter ETH")
    }

    Input {
        id: txtFrom
        label: qsTr("From account")
        text: defaultAccount
        placeholderText: qsTr("Send from (account)")
        anchors.top: txtAmount.bottom
        anchors.topMargin: Theme.padding
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
