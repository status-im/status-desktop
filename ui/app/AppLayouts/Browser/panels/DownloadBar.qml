import QtQuick
import QtWebEngine

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils

import AppLayouts.Browser.controls

Rectangle {
    id: root

    property var downloadsModel
    property var downloadsMenu

    signal openDownloadClicked(bool downloadComplete, int index)
    signal addNewDownloadTab()
    signal close()

    color: Theme.palette.background
    implicitHeight: 56
    border.width: 1
    border.color: Theme.palette.border

    // This container is to contain the downloaded elements between the parent buttons and hide the overflow
    Item {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.smallPadding
        anchors.right: showAllBtn.left
        anchors.rightMargin: Theme.smallPadding
        height: listView.height
        clip: true

        StatusListView {
            id: listView

            orientation: ListView.Horizontal
            model: downloadsModel
            height: currentItem ? currentItem.height : 0
            // This makes it show the newest on the right
            layoutDirection: Qt.RightToLeft
            spacing: Theme.smallPadding
            anchors.left: parent.left
            width: {
                // Children rect shows a warning but this works ¯\_(ツ)_/¯
                let w = 0
                for (let i = 0; i < count; i++) {
                    w += this.itemAtIndex(i).width + this.spacing
                }
                return w
            }
            interactive: false
            delegate: DownloadElement {
                id: downloadElement

                readonly property var downloadItem: downloadsModel.downloads[index]

                isPaused: downloadItem?.isPaused ?? false
                isCanceled: downloadItem?.state === WebEngineDownloadRequest.DownloadCancelled ?? false
                downloadComplete: downloadItem?.state === WebEngineDownloadRequest.DownloadCompleted ?? false
                primaryText: downloadItem?.downloadFileName ?? ""
                downloadText: {
                    if (isCanceled) {
                        return qsTr("Cancelled")
                    }
                    if (isPaused) {
                        return qsTr("Paused")
                    }
                    return "%1/%2".arg(Qt.locale().formattedDataSize(downloadItem?.receivedBytes ?? 0, 2, Locale.DataSizeTraditionalFormat)) //e.g. 14.4/109 MB
                                  .arg(Qt.locale().formattedDataSize(downloadItem?.totalBytes ?? 0, 2, Locale.DataSizeTraditionalFormat))
                }
                onItemClicked: {
                    openDownloadClicked(downloadComplete, index)
                }
                onOptionsButtonClicked: function (xVal) {
                    downloadsMenu.index = index
                    downloadsMenu.parent = downloadElement
                    downloadsMenu.x = xVal + 20
                    downloadsMenu.y = -downloadsMenu.height
                    downloadsMenu.open()
                }
            }
        }
    }

    StatusButton {
        id: showAllBtn
        size: StatusBaseButton.Size.Small
        text: qsTr("Show All")
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: closeBtn.left
        anchors.rightMargin: Theme.padding
        onClicked: {
            addNewDownloadTab()
        }
    }

    StatusFlatRoundButton {
        id: closeBtn
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.smallPadding
        icon.name: "close"
        type: StatusFlatRoundButton.Type.Quaternary
        onClicked: root.close()
    }
}
