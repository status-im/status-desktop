import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import utils 1.0

StatusModal {
    id: root

    property var rootStore

    headerSettings.title: qsTr("Download Status link")
    height: 156

    StatusDescriptionListItem {
        subTitle: qsTr("Get Status at %1").arg(Constants.externalStatusLinkWithHttps)
        tooltip.text: qsTr("Copied!")
        asset.name: "copy"
        iconButton.onClicked: {
            root.rootStore.copyToClipboard(Constants.downloadLink)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }
}
