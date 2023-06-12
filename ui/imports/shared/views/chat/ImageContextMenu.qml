import StatusQ.Popups 0.1

import utils 1.0

StatusMenu {
    id: root

    property string imageSource

    readonly property bool isGif: root.imageSource.toLowerCase().endsWith(".gif")

    StatusAction {
        text: root.isGif ? qsTr("Copy GIF") : qsTr("Copy image")
        icon.name: "copy"
        enabled: !!root.imageSource
        onTriggered: {
            Utils.copyImageToClipboardByUrl(root.imageSource)
        }
    }

    StatusAction {
        text: root.isGif ? qsTr("Download GIF") : qsTr("Download image")
        icon.name: "download"
        enabled: !!root.imageSource
        onTriggered: {
            Global.openDownloadImageDialog(root.imageSource)
        }
    }
}
