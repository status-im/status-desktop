import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils

import "../controls"

Rectangle {
    id: downloadBar

    property bool isVisible: false
    property var downloadsModel
    property var downloadsMenu

    signal openDownloadClicked(bool downloadComplete, int index)
    signal addNewDownloadTab()

    visible: isVisible && !!listView.count
    color: Theme.palette.background
    width: parent.width
    height: 56
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
                onOptionsButtonClicked: function (xVal) {
                    downloadsMenu.index = index
                    downloadsMenu.downloadComplete = Qt.binding(function() {return downloadElement.downloadComplete})
                    downloadsMenu.parent = downloadElement
                    downloadsMenu.x = xVal + 20
                    downloadsMenu.y = -downloadsMenu.height
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
        onClicked:  downloadBar.isVisible = false
    }
}
