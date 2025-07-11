import QtQuick
import QtQuick.Controls

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups

import utils

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
    onClicked: moreMenu.popup(root, 0, height + 4)

    function getExplorerName() {
        return Utils.getChainExplorerName(root.networkShortName)
    }

    StatusMenu {
        objectName: "moreMenu"
        id: moreMenu

        StatusAction {
            objectName: "externalLink"
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
            objectName: "copyButton"
            text: qsTr("Copy contract address")
            successText: qsTr("Copied")
            icon.name: "copy"
            autoDismissMenu: true
            onTriggered: ClipboardUtils.setText(root.contractAddress)
        }
    }
}
