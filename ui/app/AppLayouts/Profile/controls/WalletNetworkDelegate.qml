import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    property var network
    property bool areTestNetworksEnabled
    title: network.chainName
    asset.name: Theme.svg(network.iconUrl)
    asset.isImage: true
    width: parent.width
    leftPadding: Theme.padding
    rightPadding: Theme.padding
    components: [
        StatusBaseText {
            objectName: "testnetLabel_" + network.chainName
            text: qsTr("Sepolia testnet active")
            color: Theme.palette.baseColor1
            visible: areTestNetworksEnabled
        },
        StatusIcon {
            icon: "next"
            color: Theme.palette.baseColor1
        }
    ]
}
