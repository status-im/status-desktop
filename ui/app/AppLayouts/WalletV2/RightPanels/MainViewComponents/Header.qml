import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"
import "../../components" as WalletComponents
import "../../components/network"
import "../../Helpers"

Item {
    id: walletHeader
    anchors.left: parent.left
    anchors.right: parent.right
    height: walletAddress.y + walletAddress.height

    property var currentAccount: walletV2Model.accountsView.currentAccount
    property var changeSelectedAccount

    Row {
        id: accountRow
        spacing: 8

        StyledText {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            text: currentAccount.name
            font.weight: Font.Medium
            font.pixelSize: Style.current.mainTitlePrimaryFontSize
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
            text: currentAccount.balance.toUpperCase()
            font.pixelSize: Style.current.mainTitleSecondaryFontSize
        }
        
    }

    MouseArea {
        anchors.fill: accountRow
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            openPopup(shareModalComponent);
        }
    }

    StatusExpandableAddress {
        id: walletAddress
        address: currentAccount.address
        anchors.top: accountRow.bottom
        anchors.left: accountRow.left
        addressWidth: 180
    }

    NetworkSelect {
        id: networkSelect
        anchors.right: parent.right
    }

    Component {
        id: shareModalComponent
        ShareModal {
            onClosed: {
                destroy();
            }
        }
    }
}
