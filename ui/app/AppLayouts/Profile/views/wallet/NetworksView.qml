import QtQuick 2.13

import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
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

        Row {
            spacing: 250
            StatusBaseText {
                id: titleText
                text: qsTr("Networks")
                font.weight: Font.Bold
                font.pixelSize: 28
                color: Theme.palette.directColor1
            }

            StatusButton {
                id: addCustomNetworkButton
                type: StatusFlatRoundButton.Type.Primary
                text: qsTr("Add Custom Network")
                onClicked: {
                    root.goBack()
                }
            }
        }
        

        Item {
            height: Style.current.bigPadding
            width: parent.width
        }

        Repeater {
            id: layer1List
            model: walletStore.layer1Networks
            delegate: WalletNetworkDelegate {
                network: model
            }
        }

        StatusSectionHeadline {
            text: qsTr("Layer 2")
            topPadding: Style.current.bigPadding
            bottomPadding: Style.current.padding
        }

        Repeater {
            id: layer2List
            model: walletStore.layer2Networks
            delegate: WalletNetworkDelegate {
                network: model
            }
        }

        StatusSectionHeadline {
            text: qsTr("Testnets")
            topPadding: Style.current.bigPadding
            bottomPadding: Style.current.padding
        }

        Repeater {
            id: testList
            model: walletStore.testNetworks
            delegate: WalletNetworkDelegate {
                network: model
            }
        }
    }
}