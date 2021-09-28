import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13


import utils 1.0
import "../../../../shared"
import "../../../../shared/status"
import "../controls"
import "../panels"
import "../popups"

Item {
    id: walletHeader
    anchors.left: parent.left
    anchors.right: parent.right
    height: walletAddress.y + walletAddress.height

    property var qrCode
    property var accountsModel
    property var currentAccount
    property var enabledNetworksModel
    property var allNetworksModel
    signal copyText(string text)
    signal toggleNetwork(int chainId)

    Row {
        id: accountRow
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 24
        spacing: 8

        StyledText {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            text: walletHeader.currentAccount.name
            font.weight: Font.Medium
            font.pixelSize: 28
        }

        Rectangle {
            id: separatorDot
            width: 8
            height: 8
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            color: Style.current.primary
            radius: 50
        }

        StyledText {
            id: walletBalance
            anchors.verticalCenter: parent.verticalCenter
            text: walletHeader.currentAccount.balance.toUpperCase()
            font.pixelSize: 22
        }
    }

    MouseArea {
        anchors.fill: accountRow
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            //TOOD improve this to not use dynamic scoping
            openPopup(shareModalComponent);
        }
    }

    StatusExpandableAddress {
        id: walletAddress
        anchors.top: accountRow.bottom
        anchors.left: accountRow.left
        addressWidth: 180
        address: walletHeader.currentAccount.address
    }

    NetworkSelectPanel {
        id: networkSelect
        anchors.right: parent.right
        allNetworks: walletHeader.allNetworksModel
        enabledNetworks: walletHeader.enabledNetworksModel
        onToggleNetwork: {
            walletHeader.toggleNetwork(chainId)
        }
    }

    Component {
        id: shareModalComponent
        ShareModal {
            anchors.centerIn: parent
            qrCode: walletHeader.qrCode
            accountsModel: walletHeader.accountsModel
            selectedAccount: walletHeader.currentAccount
            onCopy: {
                walletHeader.copyText(text);
            }
            onClosed: {
                this.destroy();
            }
        }
    }
}
