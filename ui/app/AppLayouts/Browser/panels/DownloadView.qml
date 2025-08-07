import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme

import utils

import "../controls"

Rectangle {
    id: downloadView

    property alias downloadsModel: listView.model

    property var downloadsMenu

    signal openDownloadClicked(bool downloadComplete, int index)

    color: Theme.palette.background

    StatusListView {
        id: listView
        anchors {
            topMargin: Theme.bigPadding
            top: parent.top
            bottom: parent.bottom
            bottomMargin: Theme.bigPadding * 2
            horizontalCenter: parent.horizontalCenter
        }
        width: 624
        spacing: Theme.padding

        delegate: DownloadElement {
            id: downloadElement
            width: parent.width
            isPaused: downloadsModel.downloads[index] && downloadsModel.downloads[index].isPaused
            primaryText: downloadFileName
            downloadText: {
                if (isCanceled) {
                    return qsTr("Cancelled")
                }
                if (isPaused) {
                    return qsTr("Paused")
                }
                return `${downloadsModel.downloads[index] ? (downloadsModel.downloads[index].receivedBytes / 1000000).toFixed(2) : 0}/${downloadsModel.downloads[index] ? (downloadsModel.downloads[index].totalBytes / 1000000).toFixed(2) : 0} MB` //"14.4/109 MB, 26 sec left"
            }
            downloadComplete: {
                // listView.count ensures a value is returned even when index is undefined
                return listView.count > 0 && !!downloadsModel.downloads && !!downloadsModel.downloads[index] &&
                        downloadsModel.downloads[index].receivedBytes >= downloadsModel.downloads[index].totalBytes
            }
            onItemClicked: {
                openDownloadClicked(downloadComplete, index)
            }
            onOptionsButtonClicked: function(xVal) {
                downloadsMenu.index = index
                downloadsMenu.downloadComplete = Qt.binding(function() { return downloadElement.downloadComplete })
                downloadsMenu.parent = downloadElement
                downloadsMenu.x = xVal
                downloadsMenu.y = downloadView.y - downloadsMenu.height
                downloadsMenu.open()
            }
            Connections {
                target: downloadsMenu
                function onCancelClicked() {
                    isCanceled = true
                }
            }
        }
    }

    StatusBaseText {
        visible: !listView.count
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("Downloaded files will appear here.")
        color: Theme.palette.secondaryText
    }
}
