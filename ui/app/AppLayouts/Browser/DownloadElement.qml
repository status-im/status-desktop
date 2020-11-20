import QtQuick 2.1
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"


Rectangle {
    property bool downloadComplete: {
        // listView.count ensures a value is returned even when index is undefined
        return listView.count > 0 && !!downloadModel.downloads && !!downloadModel.downloads[index] && downloadModel.downloads[index].receivedBytes >= downloadModel.downloads[index].totalBytes
    }
    property bool isCanceled: false
    property bool hovered: false
    // use this to place the newest downloads first
    property int reversedIndex: listView.count - 1 - index

    id: root
    width: 272
    height: 40
    border.width: 0
    color: hovered ? Style.current.backgroundHover : Style.current.transparent
    radius: Style.current.radius

    function openFile() {
        Qt.openUrlExternally(`file://${downloadDirectory}/${downloadFileName}`)
        removeDownloadFromModel(index)
    }
    // TODO check if this works in Windows and Mac
    function openDirectory() {
        Qt.openUrlExternally("file://" + downloadDirectory)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
           root.hovered = true
        }
        onExited: {
            root.hovered = false
        }
        onClicked: {
            if (downloadComplete) {
                return openFile()
            }
            openDirectory()
        }
    }

    Loader {
        id: iconLoader
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        active: root.visible
        sourceComponent: {
            if (downloadComplete || !downloadModel.downloads[index] || downloadModel.downloads[index].isPaused || isCanceled) {
                return fileImageComponent
            }
            return loadingImageComponent
        }

        Component {
            id: loadingImageComponent
            LoadingImage {}
        }
        Component {
            id: fileImageComponent
            SVGImage {
                source: "../../img/browser/file.svg"
                width: 24
                height: 24
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: downloadComplete ? Style.current.transparent : Style.current.darkGrey
                }
            }
        }
    }

    StyledText {
        id: filenameText
        text: downloadFileName
        elide: Text.ElideRight
        anchors.left: iconLoader.right
        anchors.right: optionsBtn.left
        anchors.top:  downloadComplete ? undefined : parent.top
        anchors.verticalCenter: downloadComplete ? parent.verticalCenter : undefined
        minimumPixelSize: 13
        anchors.leftMargin: Style.current.smallPadding
        anchors.topMargin: 2
    }

    StyledText {
        id: progressText
        visible:  !downloadComplete
        color: Style.current.secondaryText
        text: {
            if (isCanceled) {
                return qsTr("Cancelled")
            }
            if (downloadModel.downloads[index] && downloadModel.downloads[index].isPaused) {
                return qsTr("Paused")
            }
            return `${downloadModel.downloads[index] ? (downloadModel.downloads[index].receivedBytes / 1000000).toFixed(2) : 0}/${downloadModel.downloads[index] ? (downloadModel.downloads[index].totalBytes / 1000000).toFixed(2) : 0} MB` //"14.4/109 MB, 26 sec left"
        }
        elide: Text.ElideRight
        anchors.left: iconLoader.right
        anchors.right: optionsBtn.left
        anchors.bottom: parent.bottom
        minimumPixelSize: 13
        anchors.leftMargin: Style.current.smallPadding
        anchors.bottomMargin: 2
    }

    StatusIconButton {
        id: optionsBtn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        icon.name: "dots-icon"
        onClicked: {
            downloadMenu.x = optionsBtn.x
            downloadMenu.open()
        }
    }

    // TODO Move this outside?
    PopupMenu {
        id: downloadMenu
        y: -height - Style.current.smallPadding

        Action {
            enabled: downloadComplete
            icon.source: "../../img/browser/file.svg"
            icon.width: 16
            icon.height: 16
            text: qsTr("Open")
            onTriggered: openFile()
        }
        Action {
            icon.source: "../../img/add_watch_only.svg"
            icon.width: 13
            icon.height: 9
            text: qsTr("Show in folder")
            onTriggered: openDirectory()
        }
        Action {
            enabled: !downloadComplete && !!downloadModel.downloads[index] && !downloadModel.downloads[index].isPaused
            icon.source: "../../img/browser/pause.svg"
            icon.width: 16
            icon.height: 16
            text: qsTr("Pause")
            onTriggered: {
                downloadModel.downloads[index].pause()
            }
        }
        Action {
            enabled: !downloadComplete && !!downloadModel.downloads[index] && downloadModel.downloads[index].isPaused
            icon.source: "../../img/browser/play.svg"
            icon.width: 16
            icon.height: 16
            text: qsTr("Resume")
            onTriggered: {
                downloadModel.downloads[index].resume()
            }
        }

        Separator {
            visible: !downloadComplete
        }

        Action {
            enabled: !downloadComplete
            icon.source: "../../img/block-icon.svg"
            icon.width: 13
            icon.height: 13
            text: qsTr("Cancel")
            onTriggered: {
                downloadModel.downloads[index].cancel()
                isCanceled = true
            }
            icon.color: Style.current.red
        }
    }
}

