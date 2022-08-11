import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    property var network
    title: network.chainName
    asset.name: Style.svg(network.iconUrl)
    asset.isImage: true
    width: parent.width
    leftPadding: Style.current.padding
    rightPadding: Style.current.padding
    components: [
        StatusIcon {
            icon: "chevron-down"
            rotation: 270
            color: Theme.palette.baseColor1
        }
    ]
}
