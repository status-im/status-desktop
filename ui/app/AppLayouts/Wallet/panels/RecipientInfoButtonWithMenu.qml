
import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusFlatButton {
    id: root

    required property string recipientAddress
    required property string networkName
    required property string networkShortName
    required property string networkBlockExplorerUrl

    signal openLink(string link)

    icon.name: "more"
    icon.color: highlighted ? Theme.palette.directColor1 : Theme.palette.directColor5

    highlighted: moreMenu.opened
    onClicked: moreMenu.popup(root, 0, height + 4)

    function getExplorerName() {
        return Utils.getChainExplorerName(root.networkShortName)
    }

    StatusMenu {
        id: moreMenu
        objectName: "moreMenu"

        StatusAction {
            objectName: "externalLink"
            //: e.g. "View receiver address on Etherscan"
            text:  qsTr("View receiver address on %1").arg(getExplorerName())
            icon.name: "external-link"
            onTriggered: {
                var link = "%1/%2/%3".arg(root.networkBlockExplorerUrl).arg(Constants.networkExplorerLinks.addressPath).arg(root.recipientAddress)
                root.openLink(link)
            }
        }
        StatusSuccessAction {
            objectName: "copyButton"
            text: qsTr("Copy receiver address")
            successText: qsTr("Copied")
            icon.name: "copy"
            autoDismissMenu: true
            onTriggered: ClipboardUtils.setText(root.recipientAddress)
        }
    }
}
