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

    property var layer1Networks
    property var layer2Networks

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width

        Repeater {
            id: layer1List
            model: layer1Networks
            delegate: WalletNetworkDelegate {
                network: model
            }
        }

        StatusSectionHeadline {
            leftPadding: Style.current.padding
            rightPadding: Style.current.padding
            text: qsTr("Layer 2")
            topPadding: Style.current.bigPadding
            bottomPadding: Style.current.padding
        }

        Repeater {
            id: layer2List
            model: layer2Networks
            delegate: WalletNetworkDelegate {
                network: model
            }
        }

        Item {
            height: Style.current.bigPadding
            width: parent.width
        }

        StatusButton {
            // Disable for now
            visible: false
            anchors.right: parent.right
            anchors.rightMargin: Style.current.bigPadding
            id: addCustomNetworkButton
            type: StatusFlatRoundButton.Type.Primary
            text: qsTr("Add Custom Network")
            onClicked: {
                root.goBack()
            }
        }
    }
}
