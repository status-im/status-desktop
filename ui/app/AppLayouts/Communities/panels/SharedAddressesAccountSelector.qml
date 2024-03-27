import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

StatusListView {
    id: root

    required property var selectedSharedAddressesMap // Map[address, [selected, isAirdrop]]

    property var walletAssetsModel
    property bool hasPermissions
    property var uniquePermissionTokenKeys

    property var getCurrencyAmount: function (balance, symbol){}

    signal toggleAddressSelection(string keyUid, string address)
    signal airdropAddressSelected (string address)

    leftMargin: d.absLeftMargin
    topMargin: Style.current.padding
    rightMargin: Style.current.padding
    bottomMargin: Style.current.padding

    QtObject {
        id: d

        readonly property int selectedSharedAddressesCount: root.selectedSharedAddressesMap.size

        // UI
        readonly property int absLeftMargin: 12

        readonly property ButtonGroup airdropGroup: ButtonGroup {
            exclusive: true
        }

        readonly property ButtonGroup addressesGroup: ButtonGroup {
            exclusive: false
        }

        function getTotalBalance(balances, decimals, symbol) {
            let totalBalance = 0
            for(let i=0; i<balances.count; i++) {
                let balancePerAddressPerChain = ModelUtils.get(balances, i)
                totalBalance += AmountsArithmetic.toNumber(balancePerAddressPerChain.balance, decimals)
            }
            return totalBalance
        }
    }

    spacing: Style.current.halfPadding
    delegate: StatusListItem {
        readonly property string address: model.address.toLowerCase()

        id: listItem
        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        statusListItemTitle.font.weight: Font.Medium
        title: model.name
        tertiaryTitle: !walletAccountAssetsModel.count && root.hasPermissions ? qsTr("No relevant tokens") : ""

        SubmodelProxyModel {
            id: filteredBalances
            sourceModel: root.walletAssetsModel
            submodelRoleName: "balances"
            delegateModel: SortFilterProxyModel {
                sourceModel: submodel
                filters: FastExpressionFilter {
                    expression: listItem.address === model.account.toLowerCase()
                    expectedRoles: ["account"]
                }
            }
        }
        tagsModel: SortFilterProxyModel {
            id: walletAccountAssetsModel
            sourceModel: filteredBalances

            function filterPredicate(symbol) {
                return root.uniquePermissionTokenKeys.includes(symbol.toUpperCase())
            }

            proxyRoles: FastExpressionRole {
                name: "enabledNetworkBalance"
                expression: d.getTotalBalance(model.balances, model.decimals, model.symbol)
                expectedRoles: ["balances", "decimals", "symbol"]
            }
            filters: FastExpressionFilter {
                expression: walletAccountAssetsModel.filterPredicate(model.symbol)
                expectedRoles: ["symbol"]
            }
            sorters: FastExpressionSorter {
                expression: {
                    if (modelLeft.enabledNetworkBalance > modelRight.enabledNetworkBalance)
                        return -1 // descending, biggest first
                    else if (modelLeft.enabledNetworkBalance < modelRight.enabledNetworkBalance)
                        return 1
                    else
                        return 0
                }
                expectedRoles: ["enabledNetworkBalance"]
            }
        }
        statusListItemInlineTagsSlot.spacing: Style.current.padding
        tagsDelegate: Row {
            spacing: 4
            StatusRoundedImage {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                image.source: Constants.tokenIcon(model.symbol.toUpperCase())
            }
            StatusBaseText {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Theme.tertiaryTextFontSize
                text: LocaleUtils.currencyAmountToLocaleString(root.getCurrencyAmount(model.enabledNetworkBalance, model.symbol))
            }
        }

        asset.color: !!model.color ? model.color : ""
        asset.emoji: model.emoji
        asset.name: !model.emoji ? "filled-account": ""
        asset.letterSize: 14
        asset.isLetterIdenticon: !!model.emoji
        asset.isImage: asset.isLetterIdenticon

        components: [
            StatusFlatButton {
                ButtonGroup.group: d.airdropGroup
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "airdrop"
                icon.color: hovered ? Theme.palette.primaryColor3 :
                                      checked ? Theme.palette.primaryColor1 : disabledTextColor
                checkable: true
                checked: {
                    let obj = root.selectedSharedAddressesMap.get(listItem.address)
                    if (!!obj) {
                        return obj.isAirdrop
                    }
                    return false
                }
                enabled: shareAddressCheckbox.checked && d.selectedSharedAddressesCount > 1 // last cannot be unchecked
                visible: shareAddressCheckbox.checked
                opacity: enabled ? 1.0 : 0.3

                onToggled: {
                    root.airdropAddressSelected(listItem.address)
                }

                StatusToolTip {
                    text: qsTr("Use this address for any Community airdrops")
                    visible: parent.hovered
                    delay: 500
                }
            },
            StatusCheckBox {
                id: shareAddressCheckbox
                ButtonGroup.group: d.addressesGroup
                anchors.verticalCenter: parent.verticalCenter
                checkable: true
                checked: root.selectedSharedAddressesMap.has(listItem.address)
                enabled: !(d.selectedSharedAddressesCount === 1 && checked) // last cannot be unchecked

                onToggled: {
                    root.toggleAddressSelection(model.keyUid, listItem.address)
                }
            }
        ]
    }
}
