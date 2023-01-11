import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

RowLayout {
    id: root

    property var store
    property var bestRoutes
    property var amountToSend
    property bool isLoading: false
    property bool isBridgeTx: false
    property var selectedAsset
    property var selectedAccount
    property var toNetworksList: []
    property var weiToEth: function(wei) {}
    property var reCalculateSuggestedRoute: function() {}
    property bool errorMode: false
    property int errorType: Constants.NoError
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
        StatusBaseText {
            Layout.maximumWidth: 410
            font.pixelSize: 15
            font.weight: Font.Medium
            color: Theme.palette.directColor1
            text: qsTr("Networks")
            wrapMode: Text.WordWrap
        }
        StatusBaseText {
            Layout.maximumWidth: 410
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: isBridgeTx ? qsTr("Choose the network to bridge token to") :
                              qsTr("The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost.")
            wrapMode: Text.WordWrap
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: row.height + 10
            Layout.topMargin: Style.current.bigPadding
            contentWidth: row.width
            contentHeight: row.height + 10
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            clip: true
            visible: !root.isLoading ? root.isBridgeTx ? true : root.errorType === Constants.NoError : false
            Column {
                id: row
                spacing: Style.current.padding
                Repeater {
                    id: repeater
                    objectName: "networksList"
                    model: isBridgeTx ? store.allNetworks : root.toNetworksList
                    delegate: isBridgeTx ? networkItem : routeItem
                }
            }
        }
        BalanceExceeded {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.current.bigPadding
            amountToSend: root.amountToSend ? root.amountToSend.amount : 0.0
            isLoading: root.isLoading
            errorType: root.errorType
        }
    }

    ButtonGroup {
        buttons: repeater.children
    }

    Component {
        id: routeItem
        StatusListItem {
            objectName: modelData.chainName
            leftPadding: 5
            rightPadding: 5
            implicitWidth: 410
            title: modelData.chainName
            subTitle: {
                let index = store.lockedInAmounts.findIndex(lockedItem => lockedItem !== undefined && lockedItem.chainID === modelData.chainId)
                var amountOut
                if(!root.errorMode || index === -1)
                    amountOut = root.weiToEth(modelData.amountOut)
                else {
                    amountOut = root.weiToEth(parseInt(store.lockedInAmounts[index].value, 16))
                }
                return LocaleUtils.currencyAmountToLocaleString(amountOut)
            }
            statusListItemSubTitle.color: root.errorMode ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
            asset.width: 32
            asset.height: 32
            asset.name: Style.svg("tiny/" + modelData.iconUrl)
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
                leftPadding: 5
                rightPadding: 5
                implicitWidth: 150
                title: chainName
                property bool tokenBalanceOnChainValid: selectedAccount && selectedAccount !== undefined && selectedAsset !== undefined
                property var tokenBalanceOnChain: tokenBalanceOnChainValid ? root.store.getTokenBalanceOnChain(selectedAccount, chainId, selectedAsset.symbol) : undefined
                subTitle: tokenBalanceOnChain ? LocaleUtils.currencyAmountToLocaleString(tokenBalanceOnChain) : "N/A"
                statusListItemSubTitle.color: Theme.palette.primaryColor1
                asset.width: 32
                asset.height: 32
                asset.name: Style.svg("tiny/" + iconUrl)
                asset.isImage: true
                color: {
                    if (sensor.containsMouse || highlighted ||  gasRectangle.checked) {
                        return Theme.palette.baseColor2
                    }
                    return Theme.palette.statusListItem.backgroundColor
                }
                onClicked: gasRectangle.toggle()
            }
            onCheckedChanged: {
                store.addRemoveDisabledToChain(chainId, !gasRectangle.checked)
                if(checked)
                    root.reCalculateSuggestedRoute()
            }
            checked: index === 0
            indicator: Item {
                width: card.width
                height: card.height
            }
            Component.onCompleted: {
                store.addRemoveDisabledToChain(chainId, !gasRectangle.checked)
                if(index === (repeater.count -1))
                    root.reCalculateSuggestedRoute()
            }
        }
    }
}
