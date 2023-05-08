import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import utils 1.0

StatusListItem {
    id: root
    property var modelData
    property bool clearVisible: false
    signal cleared()

    implicitHeight: visible ? 64 : 0
    title: !!modelData ? modelData.name: ""
    subTitle:  {
        if(!!modelData) {
            if (modelData.ens.length > 0) {
                return sensor.containsMouse ? Utils.richColorText(modelData.ens, Theme.palette.directColor1) : modelData.ens
            }
            else {
                let elidedAddress = StatusQUtils.Utils.elideText(modelData.address,6,4)
                return sensor.containsMouse ? WalletUtils.colorizedChainPrefix(modelData.chainShortNames) + Utils.richColorText(elidedAddress, Theme.palette.directColor1): modelData.chainShortNames + elidedAddress
            }
        }
        return ""
    }
    statusListItemSubTitle.elide: Text.ElideMiddle
    statusListItemSubTitle.wrapMode: Text.NoWrap
    radius: 0
    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"
    components: [
        ClearButton {
            width: 24
            height: 24
            visible: root.clearVisible
            onClicked: root.cleared()
        }
    ]
}
