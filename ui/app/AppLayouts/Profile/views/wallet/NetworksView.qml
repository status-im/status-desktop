import QtQuick 2.13

import shared.status 1.0

import "../../stores"
import utils 1.0

Column {
    id: root
    anchors.top: parent.top
    anchors.topMargin: 64
    anchors.left: parent.left
    anchors.right: parent.right

    property WalletStore walletStore

    signal goBack

    ListView {
        id: layer1List
        model: walletStore.layer1Networks
        width: parent.width
        height: layer1List.childrenRect.height
        delegate: StatusSettingsLineButton {
            text: model.chainName
        }
    }

    ListView {
        id: layer2List
        model: walletStore.layer2Networks
        width: parent.width
        height: layer2List.childrenRect.height
        delegate: StatusSettingsLineButton {
            text: model.chainName
        }
    }

    ListView {
        id: testList
        model: walletStore.testNetworks
        width: parent.width
        height: testList.childrenRect.height
        delegate: StatusSettingsLineButton {
            text: model.chainName
        }
    }
}