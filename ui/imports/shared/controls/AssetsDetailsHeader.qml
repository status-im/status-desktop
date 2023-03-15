import QtQuick 2.13
import QtQuick.Controls 2.14

import utils 1.0
import shared.controls 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Control {
    id: root

    property alias primaryText: tokenName.text
    property alias secondaryText: cryptoBalance.text
    property alias tertiaryText: fiatBalance.text
    property var balances
    property bool isLoading: false
    property string errorTooltipText
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 40
        height: 40
    }
    property var getNetworkColor: function(chainId){}
    property var getNetworkIcon: function(chainId){}
    property var formatBalance: function(balance){}

    topPadding: Style.current.padding

    contentItem: Column {
        spacing: 4
        Row {
            spacing: 8
            StatusSmartIdenticon {
                id: identiconLoader
                anchors.verticalCenter: parent.verticalCenter
                asset: root.asset
                loading: root.isLoading
            }
            StatusTextWithLoadingState {
                id: tokenName
                width: Math.min(root.width - identiconLoader.width - cryptoBalance.width - fiatBalance.width - 24, implicitWidth)
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                customColor: Theme.palette.directColor1
                loading: root.isLoading
            }
            StatusTextWithLoadingState {
                id: cryptoBalance
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                customColor: Theme.palette.baseColor1
                loading: root.isLoading
            }
            StatusBaseText {
                id: dotSeparator
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -15
                font.pixelSize: 50
                color: Theme.palette.baseColor1
                text: "."
            }
            StatusTextWithLoadingState {
                id: fiatBalance
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                customColor: Theme.palette.baseColor1
                loading: root.isLoading
            }
        }
        Row {
            spacing: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: identiconLoader.width
            Repeater {
                id: chainRepeater
                model: balances ? balances : null
                delegate: InformationTag {
                    tagPrimaryLabel.text: root.formatBalance(model.balance)
                    tagPrimaryLabel.color: root.getNetworkColor(model.chainId)
                    image.source: Style.svg("tiny/%1".arg(root.getNetworkIcon(model.chainId)))
                    loading: root.isLoading
                    rightComponent: StatusFlatRoundButton {
                        width: 14
                        height: visible ? 14 : 0
                        icon.width: 14
                        icon.height: 14
                        icon.name: "tiny/warning"
                        icon.color: Theme.palette.dangerColor1
                        tooltip.text: root.errorTooltipText
                        visible: !!root.errorTooltipText
                    }
                }
            }
        }
    }
}
