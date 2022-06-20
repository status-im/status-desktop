import QtQuick 2.13

import shared 1.0
import utils 1.0

Image {
    id: faviconImage

    property var currentTab

    width: Style.dp(24)
    height: Style.dp(24)
    sourceSize: Qt.size(width, height)
    // TODO find a better default favicon
    source: faviconImage.currentTab && !!faviconImage.currentTab.icon.toString() ? faviconImage.currentTab.icon : Style.svg("compassActive")
}
