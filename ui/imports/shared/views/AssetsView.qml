import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.controls 1.0
import shared.controls 1.0
import shared.popups 1.0
import utils 1.0

import SortFilterProxyModel 0.2


Control {
    id: root

    /**
      Expected model structure:

        key         [string] - unique identifier of a token, e.g "0x3234235"
        symbol      [string] - token's symbol e.g. "ETH" or "SNT"
        name        [string] - token's name e.g. "Ether" or "Dai"
        icon        [url]    - token's icon url
        balance     [double] - tokens balance is the commonly used unit, e.g. 1.2 for 1.2 ETH, used
                               for sorting and computing market value
        balanceText [string] - formatted and localized balance. This is not done internally because
                               it may depend on many external factors
        error       [string] - error message related to balance

        marketDetailsAvailable [bool]   - specifies if market datails are available for given token
        marketDetailsLoading   [bool]   - specifies if market datails are available for given token
        marketPrice            [double] - specifies market price in currently used currency
        marketChangePct24hour  [double] - percentage price change in last 24 hours, e.g. 0.5 for 0.5% of price change

        communityId   [string] - for community assets, unique identifier of a community, e.g. "0x6734235"
        communityName [string] - for community assets, name of a community e.g. "Crypto Kitties"
        communityIcon [url]    - for community assets, community's icon url

        position    [int]  - if custom order available, display position defined by the user via token management
        canBeHidden [bool] - specifies if given token can be hidden (e.g. ETH should be always visible)
    **/
    property var model

    // enables global loading state useful when real data are not yet available
    property bool loading

    // shows/hides list sorter
    property bool sorterVisible

    // allows/disables choosing custom sort order from a sorter
    property bool customOrderAvailable

    // switches configuring right click menu
    property bool sendEnabled: true
    property bool communitySendEnabled: false
    property bool swapEnabled: true
    property bool swapVisible: true
    property bool communitySwapVisible: false

    property string balanceError
    // banner component to be displayed on top of the list
    property alias bannerComponent: banner.sourceComponent

    // global market data error, presented for all tokens expecting market data
    property string marketDataError

    // formatting function for fiat currency values
    property var formatFiat: balance => `${balance.toLocaleString(Qt.locale())} XYZ`

    signal sendRequested(string key)
    signal receiveRequested(string key)
    signal swapRequested(string key)
    signal assetClicked(string key)
    signal communityClicked(string communityKey)
    signal hideRequested(string key)
    signal hideCommunityAssetsRequested(string communityKey)
    signal manageTokensRequested

    function setSortOrder(order) {
        d.sortOrder = order
    }

    function getSortOrder() {
        return d.sortOrder
    }

    function getSortValue() {
        return d.sortValue
    }

    function sortByValue(value) {
        d.sortValue = value
    }

    QtObject {
        id: d

        readonly property int loadingItemsCount: 25
        property int sortOrder: Qt.DescendingOrder
        property int sortValue: -1
    }

    SortFilterProxyModel {
        id: sfpm

        sourceModel: root.model ?? null

        proxyRoles: [
            // helper role for rendering section delegate
            FastExpressionRole {
                name: "isCommunity"
                expression: !!communityId ? "community" : ""
                expectedRoles: ["communityId"]
            },
            FastExpressionRole {
                name: "marketBalance"
                expression: balance * marketPrice
                expectedRoles: ["balance", "marketPrice"]
            },
            FastExpressionRole {
                name: "change1DayFiat"
                expression: marketBalance * (1 - (1 / (marketChangePct24hour / 100 + 1)))
                expectedRoles: ["marketBalance", "marketChangePct24hour"]
            }
        ]

        sorters: [
            RoleSorter {
                roleName: "isCommunity"
            },
            RoleSorter {
                roleName: sortOrderComboBox.currentSortRoleName
                sortOrder: sortOrderComboBox.currentSortOrder
            }
        ]
    }

    contentItem: ColumnLayout {
        ColumnLayout {
            Layout.fillHeight: false
            Layout.preferredHeight: root.sorterVisible ? implicitHeight : 0

            opacity: root.sorterVisible ? 1 : 0
            spacing: 20
            visible: opacity > 0

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            StatusDialogDivider { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: false

                spacing: Theme.halfPadding

                StatusBaseText {
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                    text: qsTr("Sort by:")
                }

                SortOrderComboBox {
                    id: sortOrderComboBox

                    objectName: "cmbTokenOrder"
                    hasCustomOrderDefined: root.customOrderAvailable
                    Binding on currentIndex {
                        value: {
                            sortOrderComboBox.count
                            let id = sortOrderComboBox.indexOfValue(d.sortValue)
                            if (id === -1)
                                id = sortOrderComboBox.indexOfValue(SortOrderComboBox.TokenOrderAlpha)
                            return id
                        }
                        when: sortOrderComboBox.count > 0
                    }
                    onCurrentValueChanged: d.sortValue = sortOrderComboBox.currentValue
                    Binding on currentSortOrder {
                        value: d.sortOrder
                    }
                    onCurrentSortOrderChanged: d.sortOrder = sortOrderComboBox.currentSortOrder
                    model: [
                        { value: SortOrderComboBox.TokenOrderCurrencyBalance,
                            text: qsTr("Asset balance value"), icon: "", sortRoleName: "marketBalance" },
                        { value: SortOrderComboBox.TokenOrderBalance,
                            text: qsTr("Asset balance"), icon: "", sortRoleName: "balance" },
                        { value: SortOrderComboBox.TokenOrderCurrencyPrice,
                            text: qsTr("Asset value"), icon: "", sortRoleName: "marketPrice" },
                        { value: SortOrderComboBox.TokenOrder1DChange,
                            text: qsTr("1d change: balance value"), icon: "", sortRoleName: "change1DayFiat" },
                        { value: SortOrderComboBox.TokenOrderAlpha,
                            text: qsTr("Asset name"), icon: "", sortRoleName: "name" },
                        { value: SortOrderComboBox.TokenOrderCustom,
                            text: qsTr("Custom order"), icon: "", sortRoleName: "position" },
                        { value: SortOrderComboBox.TokenOrderNone,
                            text: "---", icon: "", sortRoleName: "" }, // separator
                        { value: SortOrderComboBox.TokenOrderCreateCustom,
                            text: hasCustomOrderDefined ? qsTr("Edit custom order →") : qsTr("Create custom order →"),
                            icon: "", sortRoleName: "" }
                    ]
                    onCreateOrEditRequested: {
                        root.manageTokensRequested()
                    }
                }
            }

            StatusDialogDivider { Layout.fillWidth: true }
        }

        Loader {
            id: banner
            Layout.fillWidth: true
        }

        DelegateModel {
            id: regularModel

            model: sfpm

            delegate: TokenDelegate {
                objectName: `AssetView_TokenListItem_${model.symbol}`

                width: ListView.view.width

                name: model.name
                icon: model.icon
                balance: model.balanceText
                marketBalance: root.formatFiat(model.marketBalance)

                marketDetailsAvailable: model.marketDetailsAvailable
                marketDetailsLoading: model.marketDetailsLoading
                marketCurrencyPrice: root.formatFiat(model.change1DayFiat)
                marketChangePct24hour: model.marketChangePct24hour

                communityId: model.communityId
                communityName: model.communityName ?? ""
                communityIcon: model.communityIcon ?? ""

                errorTooltipText_1: model.error
                errorTooltipText_2: root.marketDataError

                errorMode: !!root.balanceError
                errorIcon.tooltip.text: root.balanceError

                onClicked: {
                    if (mouse.button === Qt.LeftButton)
                        root.assetClicked(model.key)
                    else if (mouse.button === Qt.RightButton)
                        tokenContextMenu.createObject(this, { model }).popup(mouse)
                }

                onCommunityClicked: root.communityClicked(model.communityId)
            }
        }

        DelegateModel {
            id: loadingModel

            model: d.loadingItemsCount

            delegate: LoadingTokenDelegate {
                objectName: `AssetView_LoadingTokenDelegate_${model.index}`

                width: ListView.view.width
            }
        }

        StatusListView {
            id: listView

            objectName: "assetViewStatusListView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.loading ? loadingModel : regularModel

            section {
                property: "isCommunity"
                delegate: AssetsSectionDelegate {
                    width: parent.width
                    text: qsTr("Community minted")
                    onInfoButtonClicked: communityInfoPopup.createObject(this).open()
                }
            }
        }
    }

    Component {
        id: tokenContextMenu

        AssetContextMenu {
            required property var model

            readonly property string key: model.key
            readonly property string communityKey: model.communityId

            readonly property bool isCommunity: !!model.isCommunity

            onClosed: destroy()

            sendEnabled: root.sendEnabled
                         && (!isCommunity || root.communitySendEnabled)
            swapEnabled: root.swapEnabled
            swapVisible: root.swapVisible && (!isCommunity || root.communitySwapVisible)
            hideVisible: model.canBeHidden
            communityHideVisible: isCommunity

            onSendRequested: root.sendRequested(key)
            onReceiveRequested: root.receiveRequested(key)
            onSwapRequested: root.swapRequested(key)

            onHideRequested: root.hideRequested(key)
            onCommunityHideRequested: root.hideCommunityAssetsRequested(communityKey)

            onManageTokensRequested: root.manageTokensRequested()
        }
    }

    Component {
        id: communityInfoPopup

        CommunityAssetsInfoPopup {
            destroyOnClose: true
        }
    }
}
