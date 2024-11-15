import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusFlatButton {
    id: root

    required property string symbol
    required property string contractAddress
    required property string networkName
    required property string networkShortName
    required property string networkBlockExplorerUrl

    signal openLink(string link)

    icon.name: "more"
    icon.color: highlighted ? Theme.palette.directColor1 : Theme.palette.directColor5

    highlighted: moreMenu.opened
    onClicked: moreMenu.popup(-moreMenu.width + width, height + 4)

    function getExplorerName() {
        return Utils.getChainExplorerName(root.networkShortName)
    }

    StatusMenu {
        id: moreMenu

        StatusAction {
            //: e.g. "View Optimism (DAI) contract address on Optimistic"
            text: !!root.symbol ? qsTr("View %1 %2 contract address on %3").arg(root.networkName).arg(root.symbol).arg(getExplorerName())
                                : qsTr("View %1 contract address on %2").arg(root.networkName).arg(getExplorerName())
            icon.name: "external-link"
            onTriggered: {
                var link = "%1/%2/%3".arg(root.networkBlockExplorerUrl).arg(Constants.networkExplorerLinks.addressPath).arg(root.contractAddress)
                root.openLink(link)
            }
        }
        StatusSuccessAction {
            text: qsTr("Copy contract address")
            successText: qsTr("Copied")
            icon.name: "copy"
            autoDismissMenu: true
            onTriggered: ClipboardUtils.setText(root.contractAddress)
        }
    }
}
