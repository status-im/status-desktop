import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"
import "./components/network"

Item {
    property var currentAccount: walletV2Model.accountsView.currentAccount
    property var changeSelectedAccount

    id: walletHeader
    height: walletAddress.y + walletAddress.height
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

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
            text: currentAccount.name
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
            text: currentAccount.balance.toUpperCase()
            font.pixelSize: 22
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
        anchors.leftMargin: 0
        anchors.topMargin: 0
    }

    NetworkSelect {
        id: networkSelect
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.right: parent.right
        anchors.rightMargin: 90
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

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
