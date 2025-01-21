import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    id: root

    property bool areTestNetworksEnabled
    property string chainName
    property string iconUrl

    title: chainName
    asset.name: Theme.svg(iconUrl)
    asset.isImage: true
    width: parent.width
    leftPadding: Theme.padding
    rightPadding: Theme.padding
    components: [
        StatusBaseText {
            objectName: "testnetLabel_" + chainName
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
