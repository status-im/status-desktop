import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    property var network
    property bool areTestNetworksEnabled
    title: network.chainName
    asset.name: Style.svg(network.iconUrl)
    asset.isImage: true
    width: parent.width
    leftPadding: Style.current.padding
    rightPadding: Style.current.padding
    components: [
        StatusBaseText {
            text: qsTr("Goerli testnet active")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            visible: areTestNetworksEnabled
        },
        StatusIcon {
            icon: "next"
            color: Theme.palette.baseColor1
        }
    ]
}
