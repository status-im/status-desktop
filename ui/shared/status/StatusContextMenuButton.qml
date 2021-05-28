import QtQuick 2.13
import "../../imports"
import "../../shared"

StatusIconButton {
    id: moreActionsBtn
    anchors.verticalCenter: parent.verticalCenter
    icon.name: "dots-icon"
    iconColor: Style.current.contextMenuButtonForegroundColor
    hoveredIconColor: Style.current.contextMenuButtonForegroundColor
    highlightedBackgroundColor: Style.current.contextMenuButtonBackgroundHoverColor
}
