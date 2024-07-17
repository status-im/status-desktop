﻿import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ 0.1

import "../controls"

RowLayout {
    id: root

    property var store
    property int minReceiveCryptoDecimals: 0
    property bool isLoading: false
    property bool isBridgeTx: false
    property bool isCollectiblesTransfer: false
    property var fromNetworksList
    property var suggestedToNetworksList
    property var weiToEth: function(wei) {}
    property var formatCurrencyAmount: function () {}
    property var reCalculateSuggestedRoute: function() {}
    property bool errorMode: false
    property int errorType: Constants.NoError
    property string selectedSymbol

    spacing: 10

    StatusRoundIcon {
        Layout.alignment: Qt.AlignTop
        radius: 8
        asset.name: "flash"
        asset.color: Theme.palette.directColor1
    }
    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: root.width
        spacing: 4
        StatusBaseText {
            Layout.maximumWidth: parent.width
            font.pixelSize: 15
            font.weight: Font.Medium
            color: Theme.palette.directColor1
            text: qsTr("Networks")
            wrapMode: Text.WordWrap
        }
        StatusBaseText {
            Layout.maximumWidth: parent.width
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: isBridgeTx ? qsTr("Routes will be automatically calculated to give you the lowest cost.") :
                              qsTr("The networks where the recipient will receive tokens. Amounts calculated automatically for the lowest cost.")
            wrapMode: Text.WordWrap
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? row.height + 10 : 0
            Layout.topMargin: Style.current.smallPadding
            contentWidth: row.width
            contentHeight: row.height + 10
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            clip: true
            visible: root.isBridgeTx ? true : !root.isLoading ? root.errorType === Constants.NoError : false
            Column {
                id: row
                spacing: Style.current.padding

                // TODO: This transformation should come from an adaptor outside this component
                LeftJoinModel {
                    id: toNetworksListLeftJoinModel

                    leftModel: root.suggestedToNetworksList
                    rightModel: root.store.flatNetworksModel
                    joinRole: "chainId"
                }

                Repeater {
                    id: repeater
                    objectName: "networksList"
                    model: isBridgeTx ? root.fromNetworksList : toNetworksListLeftJoinModel
                    delegate: isBridgeTx ? networkItem : routeItem
                }
            }
        }
        BalanceExceeded {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.current.smallPadding
            errorType: root.errorType
            isLoading: root.isLoading && !root.isBridgeTx
        }
    }

    ButtonGroup {
        buttons: repeater.children
    }

    Component {
        id: routeItem
        StatusListItem {
            objectName: model.chainName
            leftPadding: 5
            rightPadding: 5
            implicitWidth: 410
            title: model.chainName
            subTitle: {
                if(root.isCollectiblesTransfer)
                    return ""
                let amountOut = root.weiToEth(model.amountOut)
                return root.formatCurrencyAmount(amountOut, root.selectedSymbol, {"minDecimals": root.minReceiveCryptoDecimals})
            }
            statusListItemSubTitle.color: root.errorMode ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
            asset.width: 32
            asset.height: 32
            asset.name: Style.svg("tiny/" + model.iconUrl)
            asset.isImage: true
            color: "transparent"
        }
    }

    Component {
        id: networkItem
        StatusRadioButton {
            id: gasRectangle
            width: contentItem.implicitWidth
            contentItem: StatusListItem {
                id: card
                objectName: chainName
                leftPadding: 16
                rightPadding: 6
                implicitWidth: 410
                title: chainName
                subTitle: root.formatCurrencyAmount(tokenBalance.amount, root.selectedSymbol)
                statusListItemSubTitle.color: Theme.palette.primaryColor1
                asset.width: 32
                asset.height: 32
                asset.name: Style.svg("tiny/" + iconUrl)
                asset.isImage: true
                border.color: gasRectangle.checked ? Theme.palette.primaryColor1 : Theme.palette.primaryColor2
                color: {
                    if (sensor.containsMouse) {
                        return Theme.palette.baseColor2
                    }
                    Theme.palette.statusListItem.backgroundColor
                }
                onClicked: {
                    if(!gasRectangle.checked)
                        gasRectangle.toggle()
                }
            }
            onCheckedChanged: {
                store.setRouteDisabledChains(chainId, !gasRectangle.checked)
                if(checked)
                    root.reCalculateSuggestedRoute()
            }
            checked: index === 0
            indicator: Item {
                width: card.width
                height: card.height
            }
            Component.onCompleted: {
                store.setRouteDisabledChains(chainId, !gasRectangle.checked)
                if(index === (repeater.count -1))
                    root.reCalculateSuggestedRoute()
            }
        }
    }
}
