﻿import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared.controls 1.0

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

Control {
    id: root

    property alias primaryText: tokenName.text
    property alias secondaryText: cryptoBalance.text
    property alias tertiaryText: fiatBalance.text
    property alias communityTag: communityTag
    property var balances
    property int decimals
    property var networksModel
    property bool isLoading: false
    property string errorTooltipText
    property string address
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 25
        height: 25
    }
    property var formatBalance: function(balance){}

    topPadding: Theme.padding

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: 4
        readonly property bool isOverflowing:  root.width < tokenNameAndIcon.width + communityAndBalances.width + fiatBalanceLayout.width

        RowLayout {
            id: tokenNameAndIcon
            Layout.fillWidth: true
            spacing: 8
            StatusTextWithLoadingState {
                id: tokenName
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: root.width-root.asset.width-8
                font.pixelSize: Theme.fontSize28
                font.bold: true
                lineHeight: 38
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                customColor: Theme.palette.directColor1
                loading: root.isLoading
            }
            StatusSmartIdenticon {
                Layout.preferredWidth: root.asset.width
                Layout.alignment: Qt.AlignHCenter
                asset: root.asset
                loading: root.isLoading
            }
        }

        GridLayout {
            Layout.fillWidth: true
            rowSpacing: Theme.halfPadding
            columnSpacing: Theme.halfPadding
            flow: mainLayout.isOverflowing ? GridLayout.TopToBottom: GridLayout.LeftToRight

            RowLayout {
                id: fiatBalanceLayout
                Layout.fillWidth: true
                spacing: Theme.halfPadding
                StatusTextWithLoadingState {
                    id: cryptoBalance
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Theme.fontSize28
                    font.bold: true
                    lineHeight: 38
                    lineHeightMode: Text.FixedHeight
                    customColor: Theme.palette.baseColor1
                    loading: root.isLoading
                }
                StatusTextWithLoadingState {
                    id: fiatBalance
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 2
                    font.pixelSize: Theme.primaryTextFontSize
                    lineHeight: 22
                    lineHeightMode: Text.FixedHeight
                    customColor: Theme.palette.baseColor1
                    loading: root.isLoading
                }
            }

            Item {
                id: filler
                Layout.fillWidth: true
            }

            RowLayout {
                id: communityAndBalances
                Layout.fillWidth: true
                spacing: Theme.halfPadding
                InformationTag {
                    id: communityTag
                }
                Repeater {
                    id: chainRepeater
                    Layout.alignment: Qt.AlignRight
                    model: root.networksModel
                    delegate: InformationTag {
                        readonly property double aggregatedbalance: balancesAggregator.value/(10 ** root.decimals)
                        SortFilterProxyModel {
                            id: filteredBalances
                            sourceModel: root.balances
                            filters: [
                                ValueFilter {
                                    roleName: "chainId"
                                    value: model.chainId
                                },
                                ValueFilter {
                                    roleName: "account"
                                    value: root.address.toLowerCase()
                                    enabled: !!root.address
                                }
                            ]
                        }
                        SumAggregator {
                            id: balancesAggregator
                            model: filteredBalances
                            roleName: "balance"
                        }
                        tagPrimaryLabel.text: root.formatBalance(aggregatedbalance)
                        tagPrimaryLabel.color: model.chainColor
                        asset.name: Theme.svg(model.iconUrl)
                        asset.isImage: true
                        loading: root.isLoading
                        visible: balancesAggregator.value > 0
                        rightComponent: StatusFlatRoundButton {
                            width: visible ? 14 : 0
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
}
