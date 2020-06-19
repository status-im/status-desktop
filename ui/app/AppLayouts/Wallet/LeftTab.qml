import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../../shared"
import "./Components"

Item {
    property int selectedAccount: 0
    property var changeSelectedAccount: function(newIndex) {
        if (newIndex > walletModel.accounts) {
            return
        }
        selectedAccount = newIndex
        walletModel.setCurrentAccountByIndex(newIndex)
    }
    id: walletInfoContainer
    width: 340
    Layout.minimumWidth: 300

    Rectangle {
        id: walletInfoHeader
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        height: walletValueTextContainer.y + walletValueTextContainer.height + Theme.padding
        color: Theme.white
        z: 1
        border.width: 0

        StyledText {
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
            x: 16
            y: 52
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.top: title.bottom
            anchors.topMargin: Theme.padding
            height: walletAmountValue.height + totalValue.height

            TextEdit {
                id: walletAmountValue
                color: "black"
                text: walletModel.totalFiatBalance
                selectByMouse: true
                cursorVisible: true
                readOnly: true
                anchors.left: parent.left
                anchors.leftMargin: 1
                font.weight: Font.Medium
                font.pixelSize: 30
            }

            StyledText {
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

        AddAccount { x: 288 ;y: 59}
    }

    Component {
        id: walletDelegate

        Rectangle {
            property bool selected: index == selectedAccount

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
                color: selected || !iconColor ? Theme.transparent : iconColor  // change image color
            }
            StyledText {
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
            StyledText {
                id: walletAddress
                text: address
                anchors.right: parent.right
                anchors.rightMargin: parent.width/2
                elide: Text.ElideMiddle
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.smallPadding
                anchors.left: walletName.left
                anchors.leftMargin: 0
                font.pixelSize: 15
                font.weight: Font.Medium
                color: selected ? Theme.white : Theme.darkGrey
                opacity: selected ? 0.7 : 1
            }
            StyledText {
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
                    changeSelectedAccount(index)
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.bottom: parent.bottom
        anchors.top: walletInfoHeader.bottom
        spacing: 5
        anchors.right: parent.right
        anchors.left: parent.left

        delegate: walletDelegate

        ListModel {
            id: exampleWalletModel
            ListElement {
                name: "Status account"
                address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
                balance: "12.00 USD"
                iconColor: "#7CDA00"
            }

            ListElement {
                name: "Test account 1"
                address: "0x2Ef1...E0Ba"
                balance: "12.00 USD"
                iconColor: "#FA6565"
            }
            ListElement {
                name: "Status account"
                address: "0x2Ef1...E0Ba"
                balance: "12.00 USD"
                iconColor: "#7CDA00"
            }
        }

        model: walletModel.accounts
        //        model: exampleWalletModel
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:0.75;height:770;width:340}
}
##^##*/
