import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1


StatusListItem {
    property var network
    title: network.chainName
    icon.isLetterIdenticon: true
    width: parent.width
    leftPadding: 0
    rightPadding: 0
    components: [
        StatusIcon {
            icon: "chevron-down"
            rotation: 270
            color: Theme.palette.baseColor1
        }
    ]
}