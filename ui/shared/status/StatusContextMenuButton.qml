import QtQuick 2.13

import utils 1.0
import "../../shared"

StatusIconButton {
    id: moreActionsBtn
    anchors.verticalCenter: parent.verticalCenter
    icon.name: "dots-icon"
    iconColor: Style.current.contextMenuButtonForegroundColor
    hoveredIconColor: Style.current.contextMenuButtonForegroundColor
    highlightedBackgroundColor: Style.current.contextMenuButtonBackgroundHoverColor
}
