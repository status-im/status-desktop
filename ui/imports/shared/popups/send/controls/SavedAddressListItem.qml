import QtQuick

import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Core.Utils as StatusQUtils

import AppLayouts.Wallet

import utils

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
                return sensor.containsMouse ? Utils.richColorText(elidedAddress, Theme.palette.directColor1): elidedAddress
            }
        }
        return ""
    }
    statusListItemSubTitle.elide: Text.ElideMiddle
    statusListItemSubTitle.wrapMode: Text.NoWrap
    radius: 0
    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"
    components: [
        StatusClearButton {
            visible: root.clearVisible
            onClicked: root.cleared()
        }
    ]
}
