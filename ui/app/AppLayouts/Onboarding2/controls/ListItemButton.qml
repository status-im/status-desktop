import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    radius: 12
    asset.width: 32
    asset.height: 32
    asset.bgRadius: 0
    asset.bgColor: "transparent"
    asset.isImage: true
    statusListItemTitle.font.pixelSize: Theme.additionalTextSize
    statusListItemTitle.font.weight: Font.Medium
    statusListItemSubTitle.font.pixelSize: Theme.additionalTextSize
    components: [
        StatusIcon {
            icon: "next"
            width: 16
            height: 16
            color: Theme.palette.baseColor1
        }
    ]
}
