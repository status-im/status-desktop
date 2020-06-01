import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtGraphicalEffects 1.0
import "../../../imports"
import "../../../shared"
import "./Components"

Item {
    property int selectedWallet: 0
    id: walletInfoContainer
    width: 340

    Text {
        id: title
        x: 143
        y: 16
        text: qsTr("Wallet")
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
    }

    Item {
        id: walletValueTextContainer
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.top: title.bottom
        anchors.topMargin: Theme.padding
        height: walletAmountValue.height + totalValue.height

        TextEdit {
            id: walletAmountValue
            color: "black"
            text: qsTr("408.30 USD")
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: parent.left
            anchors.leftMargin: 1
            font.weight: Font.Medium
            font.pixelSize: 30
        }

        Text {
            id: totalValue
            color: Theme.darkGrey
            text: "Total value"
            anchors.left: walletAmountValue.left
            anchors.leftMargin: 0
            anchors.top: walletAmountValue.bottom
            anchors.topMargin: 0
            font.weight: Font.Medium
            font.pixelSize: 13
        }
    }

    AddAccount {}

    Component {
        id: walletDelegate

        Rectangle {
            property bool selected: index == selectedWallet

            id: rectangle
            height: 64
            color: selected ? Theme.blue : Theme.transparent
            radius: Theme.radius
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding

            Image {
                id: walletIcon
                width: 12
                height: 12
                anchors.top: parent.top
                anchors.topMargin: Theme.smallPadding
                anchors.left: parent.left
                anchors.leftMargin: Theme.padding
                source: "../../img/walletIcon.svg"
            }
            ColorOverlay {
                anchors.fill: walletIcon
                source: walletIcon
                color: selected ? Theme.transparent : "#7CDA00"  // change image color
            }
            Text {
                id: walletName
                text: name
                anchors.top: parent.top
                anchors.topMargin: Theme.smallPadding
                anchors.left: walletIcon.right
                anchors.leftMargin: 10
                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Theme.white : Theme.black
            }
            Text {
                id: walletAddress
                text: address
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.smallPadding
                anchors.left: walletName.left
                anchors.leftMargin: 0
                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Theme.white : Theme.darkGrey
                opacity: selected ? 0.7 : 1
            }
            Text {
                id: walletBalance
                text: balance
                anchors.top: parent.top
                anchors.topMargin: Theme.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Theme.padding
                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Theme.white : Theme.black
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    selectedWallet = index
                    // TODO add call to Nim to change the wallet for real
                }
            }
        }
    }

    ListView {
        id: listView
        height: 160
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: Theme.padding
        spacing: 5
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        delegate: walletDelegate

        model: ListModel {
            ListElement {
                name: "Status account"
                address: "0x2Ef1...E0Ba"
                balance: "12.00 USD"
            }

            ListElement {
                name: "Test account 1"
                address: "0x2Ef1...E0Ba"
                balance: "12.00 USD"
            }
            ListElement {
                name: "Status account"
                address: "0x2Ef1...E0Ba"
                balance: "12.00 USD"
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:0.75;height:770;width:340}D{i:2;anchors_x:82}
}
##^##*/

