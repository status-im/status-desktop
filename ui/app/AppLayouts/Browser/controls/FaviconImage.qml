import QtQuick

import StatusQ.Core.Theme

import shared

Image {
    id: faviconImage

    property var currentTab

    width: 24
    height: 24
    sourceSize: Qt.size(width, height)
    // TODO find a better default favicon
    source: faviconImage.currentTab && !!faviconImage.currentTab.icon.toString() ? faviconImage.currentTab.icon : Theme.svg("compassActive")
}
