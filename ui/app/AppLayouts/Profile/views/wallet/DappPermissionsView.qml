import QtQuick 2.13

import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import utils 1.0

import "../../stores"
import "../../controls"

Item {
    id: root
    signal goBack

    property WalletStore walletStore

    StatusFlatButton {
        id: backButton
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.bigPadding
        icon.name: "arrow-left"
        icon.height: 13.5
        icon.width: 17.5
        text: qsTr("Wallet")
        onClicked: {
            root.goBack()
        }
    }

    Column {
        id: column
        anchors.topMargin: Style.current.xlPadding
        anchors.top: backButton.bottom
        anchors.leftMargin: Style.current.xlPadding * 2
        anchors.left: root.left
        width: 560

        StatusBaseText {
            id: titleText
            text: qsTr("DApp Permissions")
            font.weight: Font.Bold
            font.pixelSize: 28
            color: Theme.palette.directColor1
        }
        

        Item {
            height: Style.current.bigPadding
            width: parent.width
        }
        PermissionsListView {
            id: permissionsList
            width: parent.width
            walletStore: root.walletStore
        }
    }
}
