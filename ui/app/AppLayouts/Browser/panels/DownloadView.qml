import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtWebEngine 1.9
import QtQuick.Layouts 1.0

import "../../../../shared"
import "../../../../shared/status"
import "../controls"

import utils 1.0

Rectangle {
    id: downloadView

    property alias downloadsModel: listView.model

    signal openDownloadClicked(bool downloadComplete, int index)

    color: Style.current.background

    ListView {
        id: listView
        anchors {
            topMargin: Style.current.bigPadding
            top: parent.top
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding * 2
            horizontalCenter: parent.horizontalCenter
        }
        width: 624
        spacing: Style.current.padding

        delegate: DownloadElement {
            id: downloadElement
            width: parent.width
            isPaused: downloadsModel.downloads[index] && downloadsModel.downloads[index].isPaused
            primaryText: downloadFileName
            downloadText: {
                if (isCanceled) {
                    //% "Cancelled"
                    return qsTrId("cancelled")
                }
                if (isPaused) {
                    //% "Paused"
                    return qsTrId("paused")
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
            onOptionsButtonClicked: {
                downloadMenu.index = index
                downloadMenu.downloadComplete = Qt.binding(function() {return downloadElement.downloadComplete})

                downloadMenu.x = xVal + 80
                downloadMenu.y = listView.y + downloadElement.y + downloadElement.height
                downloadMenu.open()
            }
            Connections {
                target: downloadMenu
                onCancelClicked: {
                    isCanceled = true
                }
            }
        }
    }

    Text {
        visible: !listView.count
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        //% "Downloaded files will appear here."
        text: qsTrId("downloaded-files-will-appear-here-")
        color: Style.current.secondaryText
    }
}
