import QtQuick 2.13
import QtQuick.Controls 2.3

import "../../../../shared"
import "../../../../shared/popups"
import "../stores"

import utils 1.0

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
        //% "Open"
        text: qsTrId("open")
        onTriggered: DownloadsStore.openFile(index)
    }
    Action {
        icon.source: Style.svg("add_watch_only")
        icon.width: 13
        icon.height: 9
        //% "Show in folder"
        text: qsTrId("show-in-folder")
        onTriggered: DownloadsStore.openDirectory(index)
    }
    Action {
        enabled: !downloadComplete && !!download && !download.isPaused
        icon.source: Style.svg("browser/pause")
        icon.width: 16
        icon.height: 16
        //% "Pause"
        text: qsTrId("pause")
        onTriggered: {
            download.pause()
        }
    }
    Action {
        enabled: !downloadComplete && !!download && download.isPaused
        icon.source: Style.svg("browser/play")
        icon.width: 16
        icon.height: 16
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
        icon.width: 13
        icon.height: 13
        //% "Cancel"
        text: qsTrId("browsing-cancel")
        onTriggered: {
            download.cancel()
            cancelClicked()
        }
        icon.color: Style.current.red
    }
}
