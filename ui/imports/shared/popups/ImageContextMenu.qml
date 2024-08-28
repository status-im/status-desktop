import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Popups 0.1
import utils 1.0

StatusMenu {
    id: root

    property string url
    property string imageSource
    property string domain
    property bool requireConfirmationOnOpen: false
    property bool isGif: root.imageSource.toLowerCase().endsWith(".gif")
    property bool isVideo: root.imageSource.toLowerCase().endsWith(".mp4")

    QtObject {
        id: d
        readonly property bool isUnfurled: (!!url&&url!=="")
    }

    StatusAction {
        text: root.isGif ? qsTr("Copy GIF") : qsTr("Copy image")
        icon.name: "copy"
        enabled: !!root.imageSource && !root.isVideo
        onTriggered: {
            ClipboardUtils.setImageByUrl(root.imageSource)
        }
    }

    StatusAction {
        text: root.isGif ? qsTr("Download GIF") : root.isVideo ? qsTr("Download video") : qsTr("Download image")
        icon.name: "download"
        enabled: !!root.imageSource
        onTriggered: {
            Global.openDownloadImageDialog(root.imageSource);
        }
    }

    StatusAction {
        text: qsTr("Copy link")
        icon.name: "copy"
        enabled: d.isUnfurled
        onTriggered: ClipboardUtils.setText(url)
    }

    StatusAction {
        text: qsTr("Open link")
        icon.name: "browser"
        enabled: d.isUnfurled
        onTriggered: requireConfirmationOnOpen ? Global.openLinkWithConfirmation(root.url, root.domain) : Global.openLink(root.url)
    }
}
