import QtQuick 2.13
import "../../../../shared"

import utils 1.0

Image {
    id: faviconImage

    property var currentTab

    width: 24
    height: 24
    sourceSize: Qt.size(width, height)
    // TODO find a better default favicon
    source: faviconImage.currentTab && !!faviconImage.currentTab.icon.toString() ? faviconImage.currentTab.icon : Style.svg("compassActive")
}
