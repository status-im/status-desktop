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
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 40
        height: 40
    }
    property var getNetworkColor: function(chainId){}
    property var getNetworkIcon: function(chainId){}

    topPadding: Style.current.padding

    contentItem: Column {
        spacing: 4
        Row {
            spacing: 8
            StatusSmartIdenticon {
                id: identiconLoader
                anchors.verticalCenter: parent.verticalCenter
                asset: root.asset
            }
            StatusBaseText {
                id: tokenName
                width: Math.min(root.width - identiconLoader.width - cryptoBalance.width - fiatBalance.width - 24, implicitWidth)
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                id: cryptoBalance
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                color: Theme.palette.baseColor1
            }
            StatusBaseText {
                id: dotSeparator
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -15
                font.pixelSize: 50
                color: Theme.palette.baseColor1
                text: "."
            }
            StatusBaseText {
                id: fiatBalance
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                color: Theme.palette.baseColor1
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
                    tagPrimaryLabel.text: model.balance
                    tagPrimaryLabel.color: root.getNetworkColor(model.chainId)
                    image.source: Style.svg("tiny/%1".arg(root.getNetworkIcon(model.chainId)))
                }
            }
        }
    }
}
