import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import utils 1.0

StatusModal {
    id: root
    anchors.centerIn: parent

    //% "Get Status at https://status.im"
    readonly property string getStatusText: qsTrId("get-status-at-https---status-im")

    property var rootStore

    //% "Download Status link"
    header.title: qsTrId("download-status-link")
    height: Style.dp(156)

    StatusDescriptionListItem {
        subTitle: root.getStatusText
        tooltip.text: qsTr("Copy to clipboard")
        icon.name: "copy"
        iconButton.onClicked: {
            root.rootStore.copyToClipboard(Constants.statusLinkPrefix)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }
}
