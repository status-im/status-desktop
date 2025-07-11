import StatusQ
import StatusQ.Components
import StatusQ.Popups

import utils

StatusModal {
    id: root

    headerSettings.title: qsTr("Download Status link")
    height: 156

    StatusDescriptionListItem {
        subTitle: qsTr("Get Status at %1").arg(Constants.externalStatusLinkWithHttps)
        tooltip.text: qsTr("Copied!")
        asset.name: "copy"
        iconButton.onClicked: {
            ClipboardUtils.setText(Constants.downloadLink)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }
}
