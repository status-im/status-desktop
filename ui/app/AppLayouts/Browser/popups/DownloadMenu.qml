import QtQuick 2.13
import QtQuick.Controls 2.3

import shared.panels 1.0
import shared.popups 1.0

import utils 1.0

import "../stores"

// TODO: replace with StatusPopupMenu
PopupMenu {
    id: downloadMenu

    property int index: -1
    property bool downloadComplete: false
    property var download: DownloadsStore.getDownload(index)

    signal cancelClicked()

    Action {
        enabled: downloadComplete
        icon.source: Style.svg("browser/file")
        icon.width: 16
        icon.height: 16
        text: qsTr("Open")
        onTriggered: DownloadsStore.openFile(index)
    }
    Action {
        icon.source: Style.svg("add_watch_only")
        icon.width: 13
        icon.height: 9
        text: qsTr("Show in folder")
        onTriggered: DownloadsStore.openDirectory(index)
    }
    Action {
        enabled: !downloadComplete && !!download && !download.isPaused
        icon.source: Style.svg("browser/pause")
        icon.width: 16
        icon.height: 16
        text: qsTr("Pause")
        onTriggered: {
            download.pause()
        }
    }
    Action {
        enabled: !downloadComplete && !!download && download.isPaused
        icon.source: Style.svg("browser/play")
        icon.width: 16
        icon.height: 16
        text: qsTr("Resume")
        onTriggered: {
            download.resume()
        }
    }
    Separator {
        visible: !downloadComplete
    }
    Action {
        enabled: !downloadComplete
        icon.source: Style.svg("block-icon")
        icon.width: 13
        icon.height: 13
        text: qsTr("Cancel")
        onTriggered: {
            download.cancel()
            cancelClicked()
        }
        icon.color: Style.current.red
    }
}
