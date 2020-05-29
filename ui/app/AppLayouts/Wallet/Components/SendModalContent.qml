import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../imports"
import "../../../../shared"

Item {
    id: element
    property alias valueInput: txtValue
    property string defaultAccount: "0x1234"

    Text {
        id: modalDialogTitle
        text: "Send"
        anchors.top: parent.top
        anchors.left: parent.left
        font.bold: true
        font.pixelSize: 17
        anchors.leftMargin: 16
        anchors.topMargin: 16
    }

    Image {
        id: closeModalImg
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.topMargin: 16
        source: "../../img/close.svg"
        MouseArea {
            id: closeModalMouseArea
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                popup.close()
            }
        }
    }

    Separator {
        id: headerSeparator
        anchors.top: modalDialogTitle.bottom
    }

    Item {
        id: modalBody
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.top: headerSeparator.bottom
        anchors.topMargin: Theme.padding
        anchors.bottom: footerSeparator.top
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 32

        Input {
            id: txtValue
            label: "Amount"
            icon: "../../../img/token-icons/eth.svg"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            placeholderText: qsTr("Enter ETH")
        }

        Input {
            id: txtFrom
            label: "From account"
            text: defaultAccount
            placeholderText: qsTr("Send from (account)")
            anchors.top: txtValue.bottom
            anchors.topMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        Input {
            id: txtTo
            label: "Recipient"
            text: defaultAccount
            placeholderText: qsTr("Send to")
            anchors.top: txtFrom.bottom
            anchors.topMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        Input {
            id: txtPassword
            label: "Password"
            placeholderText: "Enter Password"
            anchors.top: txtTo.bottom
            anchors.topMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
        }
    }

    Separator {
        id: footerSeparator
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 76
    }

    StyledButton {
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: "Send"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        onClicked: {
            let result = assetsModel.onSendTransaction(txtFrom.text,
                                                       txtTo.text,
                                                       txtValue.text,
                                                       txtPassword.text)
            console.log(result)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.75;height:480;width:640}
}
##^##*/
