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
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
        //% "Open"
        text: qsTrId("open")
        onTriggered: DownloadsStore.openFile(index)
    }
    Action {
        icon.source: Style.svg("add_watch_only")
        icon.width: Style.dp(13)
        icon.height: Style.dp(9)
        //% "Show in folder"
        text: qsTrId("show-in-folder")
        onTriggered: DownloadsStore.openDirectory(index)
    }
    Action {
        enabled: !downloadComplete && !!download && !download.isPaused
        icon.source: Style.svg("browser/pause")
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
        //% "Pause"
        text: qsTrId("pause")
        onTriggered: {
            download.pause()
        }
    }
    Action {
        enabled: !downloadComplete && !!download && download.isPaused
        icon.source: Style.svg("browser/play")
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
        //% "Resume"
        text: qsTrId("resume")
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
        icon.width: Style.dp(13)
        icon.height: Style.dp(13)
        //% "Cancel"
        text: qsTrId("browsing-cancel")
        onTriggered: {
            download.cancel()
            cancelClicked()
        }
        icon.color: Style.current.red
    }
}
