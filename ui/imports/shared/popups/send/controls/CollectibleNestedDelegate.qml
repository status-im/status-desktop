import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusListItem {
    id: root

    signal itemSelected(var selectedItem)
    signal itemHovered(var selectedItem, bool hovered)

    QtObject {
        id: d

        function selectItem() {
            root.itemSelected(model)
        }
    }

    Connections {
        target: root.sensor
        function onContainsMouseChanged() {
            root.itemHovered(model, root.sensor.containsMouse)
        }
    }

    title: name
    statusListItemTitleAside.font.pixelSize: 15
    asset.name: iconUrl ? iconUrl : ""
    asset.isImage: true
    asset.width: 32
    asset.height: 32
    statusListItemLabel.color: Theme.palette.directColor1
    statusListItemInlineTagsSlot.spacing: 0

    radius: sensor.containsMouse || root.highlighted ? 0 : 8
    color: sensor.containsMouse || root.highlighted ? Theme.palette.baseColor2 : "transparent"

    onClicked: d.selectItem()

    components: [
        StatusRoundedImage {
            width: 20
            height: 20
            image.source: Style.svg("tiny/%1".arg(networkIconUrl))
            visible: !isCollection && root.sensor.containsMouse
        },
        StatusIcon {
            icon: "tiny/chevron-right"
            color: Theme.palette.baseColor1
            width: 16
            height: 16
            visible: isCollection
        }
    ]
}
