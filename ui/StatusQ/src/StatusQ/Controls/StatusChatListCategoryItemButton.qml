import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusFlatRoundButton {
    id: statusChatListCategoryItemButton

    height: 22
    width: 22
    radius: 4

    property alias tooltip: statusToolTip

    type: StatusFlatRoundButton.Type.Secondary
    icon.width: 20
    icon.color: Theme.palette.directColor4

    color: hovered ? 
        Theme.palette.statusChatListCategoryItem.buttonHoverBackgroundColor : 
        "transparent"

    StatusToolTip {
        id: statusToolTip
        visible: !!text && parent.hovered
    }
}

