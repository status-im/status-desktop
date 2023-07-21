import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import utils 1.0

StatusListItem {
    id: root

    property var modelData
    property var getNetworkShortNames: function(chainIds){}
    property bool clearVisible: false
    signal cleared()

    objectName: !!modelData  ? modelData.name: ""

    height: visible ? 64 : 0
    title: !!modelData && !!modelData.name ? modelData.name : ""
    subTitle:{
        if(!!modelData) {
            let elidedAddress = StatusQUtils.Utils.elideText(modelData.address,6,4)
            let chainShortNames = root.getNetworkShortNames(modelData.preferredSharingChainIds)
            return sensor.containsMouse ? WalletUtils.colorizedChainPrefix(chainShortNames) ||  Utils.richColorText(elidedAddress, Theme.palette.directColor1) : elidedAddress
        }
        return ""
    }
    statusListItemSubTitle.wrapMode: Text.NoWrap
    asset.emoji: !!modelData && !!modelData.emoji ? modelData.emoji: ""
    asset.color: !!modelData ? Utils.getColorForId(modelData.colorId): ""
    asset.name: !!modelData && !modelData.emoji ? "filled-account": ""
    asset.letterSize: 14
    asset.isLetterIdenticon: !!modelData && !!modelData.emoji ? true : false
    asset.bgColor: Theme.palette.indirectColor1
    asset.width: 40
    asset.height: 40
    radius: 0
    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"
    components: [
        Column {
            anchors.verticalCenter: parent.verticalCenter
            StatusTextWithLoadingState   {
                anchors.right: parent.right
                font.pixelSize: 15
                text: LocaleUtils.currencyAmountToLocaleString(!!modelData ? modelData.currencyBalance: "")
            }
            Row {
                anchors.right: parent.right
                spacing: 6
                StatusIcon {
                    width: !!icon ? 15: 0
                    height: !!icon ? 15 : 0
                    color: Theme.palette.directColor1
                    icon: modelData.walletType === Constants.watchWalletType ? "show" : ""
                }
                StatusIcon {
                    width: !!icon ? 15: 0
                    height: !!icon ? 15 : 0
                    color: Theme.palette.directColor1
                    icon: modelData.migratedToKeycard ? "keycard" : ""
                }
            }
        },
        ClearButton {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            visible: root.clearVisible
            onClicked: root.cleared()
        }
    ]
}
