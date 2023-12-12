import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0

StatusListItem {
    id: root

    // expected roles: name, symbol, enabledNetworkBalance, enabledNetworkCurrencyBalance, currencyPrice, changePct24hour, communityId, communityName, communityImage

    property alias currencyBalance: currencyBalance
    property alias change24HourPercentage: change24HourPercentageText
    property alias currencyPrice: currencyPrice

    property string currentCurrencySymbol
    property string textColor: {
        if (!modelData) {
            return Theme.palette.successColor1
        }
        return modelData.changePct24hour === undefined  ?
            Theme.palette.baseColor1 :
            modelData.changePct24hour === 0 ?
                Theme.palette.baseColor1 :
                modelData.changePct24hour < 0 ?
                    Theme.palette.dangerColor1 :
                    Theme.palette.successColor1
    }
        
    property string errorTooltipText_1
    property string errorTooltipText_2

    readonly property bool isCommunityToken: !!modelData && !!modelData.communityId
    readonly property string symbolUrl: {
        if (!modelData)
            return ""
        if (modelData.imageUrl)
            return modelData.imageUrl
        if (modelData.symbol)
            return Constants.tokenIcon(modelData.symbol, false)
        return ""
    }
    readonly property string upDownTriangle: {
        if (!modelData)
            return ""
        if (modelData.changePct24hour < 0)
            return "▾"
        if (modelData.changePct24hour > 0)
            return "▴"
        return ""
    }

    signal switchToCommunityRequested(string communityId)

    title: modelData ? modelData.name : ""
    subTitle: LocaleUtils.currencyAmountToLocaleString(modelData.enabledNetworkBalance)
    asset.name: symbolUrl
    asset.isImage: true
    asset.width: 32
    asset.height: 32
    errorIcon.tooltip.maxWidth: 300

    statusListItemTitleIcons.sourceComponent: StatusFlatRoundButton {
        width: 14
        height: visible ? 14 : 0
        icon.width: 14
        icon.height: 14
        icon.name: "tiny/warning"
        icon.color: Theme.palette.dangerColor1
        tooltip.text: root.errorTooltipText_1
        tooltip.maxWidth: 300
        visible: !!tooltip.text
    }

    components: [
        Column {
            anchors.verticalCenter: parent.verticalCenter
            StatusFlatRoundButton {
                id: errorIcon
                width: 14
                height: visible ? 14 : 0
                icon.width: 14
                icon.height: 14
                icon.name: "tiny/warning"
                icon.color: Theme.palette.dangerColor1
                tooltip.text: root.errorTooltipText_2
                tooltip.maxWidth: 200
                visible: !!tooltip.text
            }
            StatusTextWithLoadingState   {
                id: currencyBalance
                anchors.right: parent.right
                text: modelData ? LocaleUtils.currencyAmountToLocaleString(modelData.enabledNetworkCurrencyBalance) : ""
                visible: !errorIcon.visible && !root.isCommunityToken
            }
            Row {
                anchors.right: parent.right
                spacing: 6
                visible: !errorIcon.visible && !root.isCommunityToken
                StatusTextWithLoadingState {
                    id: change24HourPercentageText
                    anchors.verticalCenter: parent.verticalCenter
                    customColor: root.textColor
                    font.pixelSize: 13
                    text: modelData && modelData.changePct24hour !== undefined ? "%1 %2%".arg(root.upDownTriangle).arg(LocaleUtils.numberToLocaleString(modelData.changePct24hour, 2))
                                                                               : "---"
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 12
                    color: Theme.palette.directColor9
                }
                StatusTextWithLoadingState {
                    id: currencyPrice
                    anchors.verticalCenter: parent.verticalCenter
                    customColor: root.textColor
                    font.pixelSize: 13
                    text: modelData ? LocaleUtils.currencyAmountToLocaleString(modelData.currencyPrice) : ""
                }
            }
            ManageTokensCommunityTag {
                anchors.right: parent.right
                text: modelData && !!modelData.communityName ? modelData.communityName : ""
                imageSrc: modelData && !!modelData.communityImage ? modelData.communityImage : ""
                visible: root.isCommunityToken
                StatusToolTip {
                    text: modelData ? qsTr("This token was minted by the %1 community").arg(modelData.communityName) : ""
                    visible: parent.hovered
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onSingleTapped: root.switchToCommunityRequested(modelData.communityId)
                }
            }
        }
    ]

    states: [
        State {
            name: "unknownToken"
            when: !root.symbolUrl
            PropertyChanges {
                target: root.asset
                isLetterIdenticon: true
                color: Theme.palette.miscColor5
                name: !!modelData && modelData.symbol ? modelData.symbol : ""
            }
        }
    ]
}
