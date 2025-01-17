import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusFlatButton {
    id: root

    /** Input property holding selected recipient address **/
    required property string recipientAddress
    /** Input property holding selected network name **/
    required property string networkName
    /** Input property holding selected network short name **/
    required property string networkShortName
    /** Input property holding selected network explorer url **/
    required property string networkBlockExplorerUrl

    /** Signal to launch link **/
    signal openLink(string link)

    QtObject {
        id: d

        function getExplorerName() {
            return Utils.getChainExplorerName(root.networkShortName)
        }
    }

    icon.name: "more"
    icon.color: highlighted ? Theme.palette.directColor1 : Theme.palette.directColor5
    highlighted: moreMenu.opened
    onClicked: moreMenu.popup(root, 0, height + 4)

    StatusMenu {
        id: moreMenu
        objectName: "moreMenu"

        StatusAction {
            objectName: "externalLink"
            //: e.g. "View receiver address on Etherscan"
            text:  qsTr("View receiver address on %1").arg(d.getExplorerName())
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
