import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Models 0.1
import StatusQ.Internal 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import shared.stores 1.0
import shared.controls 1.0
import shared.popups 1.0

import AppLayouts.Wallet.controls 1.0

ColumnLayout {
    id: root

    // expected roles: name, symbol, balances, currencyPrice, changePct24hour, communityId, communityName, communityImage
    required property var assets

    property var currencyStore
    property var networkConnectionStore
    property var overview
    property bool assetDetailsLaunched: false
    property bool filterVisible
    property bool areAssetsLoading: false
    property string addressFilters
    property string networkFilters

    signal assetClicked(var token)
    signal sendRequested(string symbol)
    signal receiveRequested(string symbol)
    signal switchToCommunityRequested(string communityId)
    signal manageTokensRequested()

    spacing: 0

    QtObject {
        id: d
        property int selectedAssetIndex: -1
        readonly property int loadingItemsCount: 25

        readonly property bool isCustomView: cmbTokenOrder.currentValue === SortOrderComboBox.TokenOrderCustom

        function tokenIsVisible(symbol, currencyBalance) {
            // NOTE Backend returns ETH, SNT, STT and DAI by default
            if (!d.controller.filterAcceptsSymbol(symbol)) // explicitely hidden
                return false
            // Received tokens can have 0 balance, which indicate previosuly owned token
            return true // TODO handle UI threshold (#12611)
        }

        readonly property var controller: ManageTokensController {
            settingsKey: "WalletAssets"
        }

        function hideAllCommunityTokens(communityId) {
            const tokenSymbols = ModelUtils.getAll(assetsListView.model, "symbol", "communityId", communityId)
            d.controller.settingsHideCommunityTokens(communityId, tokenSymbols)
        }

        readonly property SubmodelProxyModel assetsWithFilteredBalances: SubmodelProxyModel {
            id: assetsWithFilteredBalances
            sourceModel: root.assets
            submodelRoleName: "balances"
            delegateModel: SortFilterProxyModel {
                sourceModel: submodel
                filters: FastExpressionFilter {
                    expression: {
                        root.networkFilters
                        root.addressFilters
                        return root.networkFilters.split(":").includes(model.chainId+"") &&
                                (!!root.addressFilters ? root.addressFilters.toUpperCase() === model.account.toUpperCase() : true)
                    }
                    expectedRoles: ["chainId", "account"]
                }
            }
        }

        function getTotalBalance(balances, decimals) {
            let totalBalance = 0
            for(let i=0; i<balances.count; i++) {
                totalBalance+=SQUtils.AmountsArithmetic.toNumber(ModelUtils.get(balances, i, "balance"), decimals)
            }
            return totalBalance
        }

        property SortFilterProxyModel customSFPM: SortFilterProxyModel {
            sourceModel: d.assetsWithFilteredBalances
            proxyRoles: [
                FastExpressionRole {
                    id: filter
                    name: "currentBalance"
                    expression: d.getTotalBalance(model.balances, model.decimals, root.addressFilters, root.networkFilters)
                    expectedRoles: ["balances", "decimals"]
                },
                FastExpressionRole {
                    name: "currentCurrencyBalance"
                    expression: {
                        if(!model.communityId) {
                            return model.currentBalance * model.marketDetails.currencyPrice.amount
                        }
                        else {
                            return model.currentBalance
                        }
                    }
                    expectedRoles: ["marketDetails", "communityId", "currentBalance"]
                },
                FastExpressionRole {
                    name: "tokenPrice"
                    expression: model.marketDetails.currencyPrice.amount
                    expectedRoles: ["marketDetails"]
                },
                FastExpressionRole {
                    name: "changePct24hour"
                    expression: model.marketDetails.changePct24hour
                    expectedRoles: ["marketDetails"]
                },
                FastExpressionRole {
                    name: "isCommunityAsset"
                    expression: !!model.communityId
                    expectedRoles: ["communityId"]
                }
            ]
            filters: [
                FastExpressionFilter {
                    expression: {
                        d.controller.settingsDirty
                        return d.tokenIsVisible(model.symbol, model.currentCurrencyBalance)
                    }
                    expectedRoles: ["symbol", "currentCurrencyBalance"]
                }
            ]
            sorters: [
                RoleSorter {
                    roleName: "isCommunityAsset"
                },
                FastExpressionSorter {
                    expression: {
                        d.controller.settingsDirty
                        return d.controller.lessThan(modelLeft.symbol, modelRight.symbol)
                    }
                    enabled: d.isCustomView
                    expectedRoles: ["symbol"]
                },
                RoleSorter {
                    roleName: cmbTokenOrder.currentSortRoleName
                    sortOrder: cmbTokenOrder.currentSortOrder
                    enabled: !d.isCustomView
                }
            ]
        }
    }

    Settings {
        category: "AssetsViewSortSettings"
        property alias currentSortField: cmbTokenOrder.currentIndex
        property alias currentSortOrder: cmbTokenOrder.currentSortOrder
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.filterVisible ? implicitHeight : 0
        spacing: 20
        opacity: root.filterVisible ? 1 : 0

        Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        StatusDialogDivider {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.halfPadding

            StatusBaseText {
                color: Theme.palette.baseColor1
                font.pixelSize: Style.current.additionalTextSize
                text: qsTr("Sort by:")
            }

            SortOrderComboBox {
                id: cmbTokenOrder
                hasCustomOrderDefined: d.controller.hasSettings
                model: [
                    { value: SortOrderComboBox.TokenOrderCurrencyBalance, text: qsTr("Asset balance value"), icon: "token-sale", sortRoleName: "currentCurrencyBalance" }, // custom SFPM ExpressionRole on "enabledNetworkCurrencyBalance" amount
                    { value: SortOrderComboBox.TokenOrderBalance, text: qsTr("Asset balance"), icon: "channel", sortRoleName: "currentBalance" }, // custom SFPM ExpressionRole on "enabledNetworkBalance" amount
                    { value: SortOrderComboBox.TokenOrderCurrencyPrice, text: qsTr("Asset value"), icon: "token", sortRoleName: "tokenPrice" }, // custom SFPM ExpressionRole on "currencyPrice" amount
                    { value: SortOrderComboBox.TokenOrder1WChange, text: qsTr("1d change: balance value"), icon: "history", sortRoleName: "changePct24hour" }, // FIXME changePct1week role missing in backend!!!
                    { value: SortOrderComboBox.TokenOrderAlpha, text: qsTr("Asset name"), icon: "bold", sortRoleName: "name" },
                    { value: SortOrderComboBox.TokenOrderCustom, text: qsTr("Custom order"), icon: "exchange", sortRoleName: "" },
                    { value: SortOrderComboBox.TokenOrderNone, text: "---", icon: "", sortRoleName: "" }, // separator
                    { value: SortOrderComboBox.TokenOrderCreateCustom, text: hasCustomOrderDefined ? qsTr("Edit custom order →") : qsTr("Create custom order →"),
                        icon: "", sortRoleName: "" }
                ]
                onCreateOrEditRequested: {
                    root.manageTokensRequested()
                }
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
        }
    }

    StatusListView {
        id: assetsListView
        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        Layout.preferredHeight: contentHeight
        Layout.fillHeight: true
        objectName: "assetViewStatusListView"
        model: root.areAssetsLoading ? d.loadingItemsCount : d.customSFPM
        delegate: delegateLoader
        section {
            property: "isCommunityAsset"
            delegate: Loader {
                width: ListView.view.width
                required property string section
                sourceComponent: section === "true" ? sectionDelegate : null
            }
        }
    }

    Component {
        id: sectionDelegate
        ColumnLayout {
            width: parent.width
            spacing: 0

            StatusDialogDivider {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.padding
                Layout.bottomMargin: Style.current.halfPadding
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Style.current.padding
                Layout.rightMargin: Style.current.smallPadding
                Layout.bottomMargin: 4
                StatusBaseText {
                    text: qsTr("Community assets")
                    color: Theme.palette.baseColor1
                }
                Item { Layout.fillWidth: true }
                StatusFlatButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    icon.name: "info"
                    textColor: Theme.palette.baseColor1
                    horizontalPadding: 0
                    verticalPadding: 0
                    onClicked: Global.openPopup(communityInfoPopupCmp)
                }
            }
        }
    }

    Component {
        id: delegateLoader
        Loader {
            property var modelData: model
            property int delegateIndex: index
            width: ListView.view.width
            sourceComponent: root.areAssetsLoading ? loadingTokenDelegate : tokenDelegate
        }
    }

    Component {
        id: loadingTokenDelegate
        LoadingTokenDelegate {
            objectName: "AssetView_LoadingTokenDelegate_" + delegateIndex
        }
    }

    Component {
        id: tokenDelegate
        TokenDelegate {
            objectName: "AssetView_TokenListItem_" + (!!modelData ? modelData.symbol : "")
            readonly property string balance: !!modelData && !!modelData.currentBalance ? "%1".arg(modelData.currentBalance) : "" // Needed for the tests
            errorTooltipText_1: !!modelData && !!networkConnectionStore ? networkConnectionStore.getBlockchainNetworkDownTextForToken(modelData.balances) : ""
            errorTooltipText_2: !!networkConnectionStore ? networkConnectionStore.getMarketNetworkDownText() : ""
            subTitle: {
                if (!modelData || !modelData.symbol) {
                    return ""
                }
                if (networkConnectionStore && networkConnectionStore.noTokenBalanceAvailable) {
                    return ""
                }
                return LocaleUtils.currencyAmountToLocaleString(root.currencyStore.getCurrencyAmount(modelData.currentBalance, modelData.symbol))
            }
            currencyBalance.text: {
                let totalCurrencyBalance = modelData && modelData.currentCurrencyBalance ? modelData.currentCurrencyBalance : 0
                return LocaleUtils.currencyAmountToLocaleString(root.currencyStore.getCurrentCurrencyAmount(totalCurrencyBalance))
            }
            errorMode: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCache && !networkConnectionStore.noMarketConnectionAndNoCache : false
            errorIcon.tooltip.text: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCacheText : ""
            onClicked: (itemId, mouse) => {
                           if (mouse.button === Qt.LeftButton) {
                               RootStore.getHistoricalDataForToken(modelData.symbol, root.currencyStore.currentCurrency)
                               d.selectedAssetIndex = delegateIndex
                               assetClicked(assetsListView.model.get(delegateIndex))
                           } else if (mouse.button === Qt.RightButton) {
                               Global.openMenu(tokenContextMenu, this,
                                               {symbol: modelData.symbol, assetName: modelData.name, assetImage: symbolUrl,
                                                   communityId: modelData.communityId, communityName: modelData.communityName, communityImage: modelData.communityImage})
                           }
                       }
            onSwitchToCommunityRequested: root.switchToCommunityRequested(communityId)
            Component.onCompleted: {
                // on Model reset if the detail view is shown, update the data in background.
                if(root.assetDetailsLaunched && delegateIndex === d.selectedAssetIndex) {
                    assetClicked(assetsListView.model.get(delegateIndex))
                }
            }
        }
    }

    Component {
        id: tokenContextMenu
        StatusMenu {
            onClosed: destroy()

            property string symbol
            property string assetName
            property string assetImage
            property string communityId
            property string communityName
            property string communityImage

            StatusAction {
                enabled: root.networkConnectionStore.sendBuyBridgeEnabled && !root.overview.isWatchOnlyAccount && root.overview.canSend
                icon.name: "send"
                text: qsTr("Send")
                onTriggered: root.sendRequested(symbol)
            }
            StatusAction {
                icon.name: "receive"
                text: qsTr("Receive")
                onTriggered: root.receiveRequested(symbol)
            }
            StatusMenuSeparator {}
            StatusAction {
                icon.name: "settings"
                text: qsTr("Manage tokens")
                onTriggered: root.manageTokensRequested()
            }
            StatusAction {
                enabled: symbol !== "ETH"
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide asset")
                onTriggered: Global.openPopup(confirmHideAssetPopup, {symbol, assetName, assetImage, communityId})
            }
            StatusAction {
                enabled: !!communityId
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide all assets from this community")
                onTriggered: Global.openPopup(confirmHideCommunityAssetsPopup, {communityId, communityName, communityImage})
            }
        }
    }

    Component {
        id: communityInfoPopupCmp
        StatusDialog {
            destroyOnClose: true
            title: qsTr("What are community assets?")
            standardButtons: Dialog.Ok
            width: 520
            contentItem: StatusBaseText {
                wrapMode: Text.Wrap
                text: qsTr("Community assets are assets that have been minted by a community. As these assets cannot be verified, always double check their origin and validity before interacting with them. If in doubt, ask a trusted member or admin of the relevant community.")
            }
        }
    }

    Component {
        id: confirmHideAssetPopup
        ConfirmationDialog {
            property string symbol
            property string assetName
            property string assetImage
            property string communityId

            readonly property string formattedName: assetName + (communityId ? " (" + qsTr("community asset") + ")" : "")

            width: 520
            destroyOnClose: true
            confirmButtonLabel: qsTr("Hide %1").arg(assetName)
            cancelBtnType: ""
            showCancelButton: true
            headerSettings.title: qsTr("Hide %1").arg(formattedName)
            headerSettings.asset.name: assetImage
            confirmationText: qsTr("Are you sure you want to hide %1? You will no longer see or be able to interact with this asset anywhere inside Status.").arg(formattedName)
            onCancelButtonClicked: close()
            onConfirmButtonClicked: {
                d.controller.settingsHideToken(symbol)
                close()
                Global.displayToastMessage(
                            qsTr("%1 was successfully hidden. You can toggle asset visibility via %2.").arg(formattedName)
                            .arg(`<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.wallet}/${Constants.walletSettingsSubsection.manageAssets}">` + qsTr("Settings", "Go to Settings") + "</a>"),
                            "",
                            "checkmark-circle",
                            false,
                            Constants.ephemeralNotificationType.success,
                            ""
                            )
            }
        }
    }

    Component {
        id: confirmHideCommunityAssetsPopup
        ConfirmationDialog {
            property string communityId
            property string communityName
            property string communityImage

            width: 520
            destroyOnClose: true
            confirmButtonLabel: qsTr("Hide all assets minted by this community")
            cancelBtnType: ""
            showCancelButton: true
            headerSettings.title: qsTr("Hide %1 community assets").arg(communityName)
            headerSettings.asset.name: communityImage
            confirmationText: qsTr("Are you sure you want to hide all community assets minted by %1? You will no longer see or be able to interact with these assets anywhere inside Status.").arg(communityName)
            onCancelButtonClicked: close()
            onConfirmButtonClicked: {
                d.hideAllCommunityTokens(communityId)
                close()
                Global.displayToastMessage(
                            qsTr("%1 community assets were successfully hidden. You can toggle asset visibility via %2.").arg(communityName)
                            .arg(`<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.wallet}/${Constants.walletSettingsSubsection.manageAssets}">` + qsTr("Settings", "Go to Settings") + "</a>"),
                            "",
                            "checkmark-circle",
                            false,
                            Constants.ephemeralNotificationType.success,
                            ""
                            )
            }
        }
    }
}
