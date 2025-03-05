import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import utils 1.0

StatusListItem {
    id: root

    property bool clearVisible: false

    required property string name
    required property string address
    required property string emoji
    required property string walletColor
    required property var currencyBalance
    required property string walletType
    required property bool migratedToKeycard
    /*
        formattedBalance    [string] - formatted balance e.g. "1234.56B"
        balance             [string] - balance e.g. "123456000000"
        iconUrl             [string] - icon url e.g. "network/Network=Hermez"
        chainColor          [string] - chain color e.g. "#FF0000"
    */
    property var accountBalance: null

    signal cleared()

    objectName: root.name

    height: visible ? 64 : 0
    title: root.name
    subTitle:{
        if(!!root.address) {
            let elidedAddress = StatusQUtils.Utils.elideAndFormatWalletAddress(root.address)
            return sensor.containsMouse ?  Utils.richColorText(elidedAddress, Theme.palette.directColor1) : elidedAddress
        }
        return ""
    }
    statusListItemSubTitle.wrapMode: Text.NoWrap
    statusListItemSubTitle.font.family: Theme.monoFont.name
    asset.emoji: root.emoji
    asset.color: root.walletColor
    asset.name: root.emoji ? "filled-account": ""
    asset.letterSize: 14
    asset.isLetterIdenticon: !!root.emoji
    asset.bgColor: Theme.palette.indirectColor1
    asset.width: 40
    asset.height: 40
    radius: 0
    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"
    components: [
        Column {
            anchors.verticalCenter: parent.verticalCenter
            StatusTextWithLoadingState   {
                objectName: "walletAccountCurrencyBalance"
                anchors.right: parent.right
                font.pixelSize: 15
                text: !!root.currencyBalance ? LocaleUtils.currencyAmountToLocaleString(root.currencyBalance) : ""
            }
            StatusIcon {
                objectName: "walletAccountTypeIcon"
                anchors.right: parent.right
                width: !!icon ? 15: 0
                height: !!icon ? 15 : 0
                color: Theme.palette.directColor1
                icon: root.walletType === Constants.watchWalletType ? "show" :
                                    root.migratedToKeycard ? "keycard" : ""
            }
        },
        StatusClearButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.clearVisible
            onClicked: root.cleared()
        }
    ]

    tagsScrollBarVisible: false
    inlineTagModel: !!root.accountBalance && !!root.accountBalance.formattedBalance ? 1 : 0
    inlineTagDelegate: StatusListItemTag {
        objectName: "inlineTagDelegate_" +  index
        background: null
        height: 16
        asset.height: 16
        asset.width: 16
        title: root.accountBalance.formattedBalance
        titleText.font.pixelSize: 12
        titleText.color: root.accountBalance.balance === "0" ? Theme.palette.baseColor1 : Theme.palette.directColor1
        asset.isImage: true
        asset.name: Theme.svg(root.accountBalance.iconUrl)
        asset.color: root.accountBalance.chainColor
        closeButtonVisible: false
        hoverEnabled: true
        tagClickable: true
        onTagClicked: root.clicked(root.itemId, mouse)
        onClicked: root.clicked(root.itemId, mouse)
    }
}
