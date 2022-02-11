import QtQuick 2.13

import shared.status 1.0

import "../../stores"

Column {
    id: root
    anchors.top: parent.top
    anchors.topMargin: 64
    anchors.left: parent.left
    anchors.right: parent.right

    property WalletStore walletStore

    signal goToNetworksView()

    StatusSettingsLineButton {
        text: qsTr("Networks")
        onClicked: goToNetworksView()
    }
}