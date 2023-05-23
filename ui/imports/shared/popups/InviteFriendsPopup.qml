import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import utils 1.0

StatusModal {
    id: root
    anchors.centerIn: parent

    readonly property string getStatusText: qsTr("Get Status at https://status.im")

    property var rootStore

    headerSettings.title: qsTr("Download Status link")
    height: 156

    StatusDescriptionListItem {
        subTitle: root.getStatusText
        tooltip.text: qsTr("Copy to clipboard")
        asset.name: "copy"
        iconButton.onClicked: {
            root.rootStore.copyToClipboard(Constants.statusLinkPrefix)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }
}
