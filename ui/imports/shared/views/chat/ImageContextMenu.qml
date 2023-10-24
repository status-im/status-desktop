import QtQuick 2.15
import StatusQ.Popups 0.1
import utils 1.0

StatusMenu {
    id: root

    property string url
    property string imageSource
    property string domain
    property bool requireConfirmationOnOpen: false

    QtObject {
        id: d
        readonly property bool isUnfurled: (!!url&&url!=="")
        readonly property bool isGif: root.imageSource.toLowerCase().endsWith(".gif")
    }

    StatusAction {
        text: d.isGif ? qsTr("Copy GIF") : qsTr("Copy image")
        icon.name: "copy"
        enabled: !!root.imageSource
        onTriggered: {
            Utils.copyImageToClipboardByUrl(root.imageSource)
        }
    }

    StatusAction {
        text: d.isGif ? qsTr("Download GIF") : qsTr("Download image")
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
        onTriggered: Utils.copyToClipboard(url)
    }

    StatusAction {
        text: qsTr("Open link")
        icon.name: "browser"
        enabled: d.isUnfurled
        onTriggered: requireConfirmationOnOpen ? Global.openLinkWithConfirmation(root.url, root.domain) : Global.openLink(root.url)
    }
}
