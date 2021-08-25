import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1

StatusFlatRoundButton {
    id: statusChatListCategoryItemButton

    height: 22
    width: 22
    radius: 4

    property bool highlighted: false
    property StatusTooltipSettings tooltip: StatusTooltipSettings {}

    type: StatusFlatRoundButton.Type.Secondary
    icon.width: 20
    icon.color: Theme.palette.directColor4

    color: hovered || highlighted ? 
        Theme.palette.statusChatListCategoryItem.buttonHoverBackgroundColor : 
        "transparent"

    StatusToolTip {
        id: statusToolTip
        visible: !!text && parent.hovered
        text: tooltip.text
        orientation: tooltip.orientation
        offset: tooltip.offset
    }
}

