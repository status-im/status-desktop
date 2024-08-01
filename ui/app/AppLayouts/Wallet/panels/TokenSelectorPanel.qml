import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.views 1.0
import shared.controls 1.0
import utils 1.0

import SortFilterProxyModel 0.2

/**
  Two-tabs panel holding searchable lists of assets (single level) and
  collectibles (two levels).

  Structure:

  TabBar (assets, collectibles)
  StackLayout (current index bound to tab bar's current index)
      Assets List  (assets part)
      StackView    (collectibles part)
         Collectibles List (top level - groups by collection/community)
         Collectibles List (nested level, on demand)
*/
Control {
    id: root

    enum Tabs {
        Assets = 0,
        Collectibles = 1
    }

    /**
     Expected model structure:

        tokensKey               [string] - unique asset's identifier
        name                    [string] - asset's name
        symbol                  [string] - asset's symbol
        iconSource              [url]    - asset's icon
        currencyBalanceAsString [string] - formatted balance
        balances                [model]  - submodel of balances per chain
            balanceAsString     [string] - formatted balance per chain
            iconUrl             [url]    - chain's icon
    **/
    property alias assetsModel: assetsSfpm.sourceModel

    /**
      Expected model structure:

        groupName           [string] - group name
        icon                [url]    - icon image of a group
        type                [string] - group type, can be "community" or "other"
        subitems            [model]  - submodel of collectibles/collections of the group
            key             [string] - balance
            name            [string] - name of the subitem
            balance         [int]    - balance of the subitem
            icon            [url]    - icon of the subitem
    **/
    property alias collectiblesModel: collectiblesSfpm.sourceModel

    // Index of the current tab, indexes ​​correspond to the Tabs enum values.
    property alias currentTab: tabBar.currentIndex

    signal assetSelected(string key)
    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    property string highlightedKey: ""

    SortFilterProxyModel {
        id: assetsSfpm

        filters: AnyOf {
            SearchFilter {
                roleName: "name"
                searchPhrase: assetsSearchBox.text
            }
            SearchFilter {
                roleName: "symbol"
                searchPhrase: assetsSearchBox.text
            }
        }
    }

    SortFilterProxyModel {
        id: collectiblesSfpm

        filters: SearchFilter {
            roleName: "groupName"
            searchPhrase: collectiblesSearchBox.text
        }
    }

    component SearchFilter: RegExpFilter {
        required property string searchPhrase

        pattern: `*${searchPhrase}*`
        caseSensitivity : Qt.CaseInsensitive
        syntax: RegExpFilter.Wildcard
    }

    component Search: SearchBox {
        input.leftPadding: root.leftPadding
        input.rightPadding: root.leftPadding
        minimumHeight: 56
        maximumHeight: 56
        input.showBackground: false
        focus: visible
    }

    contentItem: ColumnLayout {
        StatusTabBar {
            id: tabBar

            visible: !!root.assetsModel && !!root.collectiblesModel

            currentIndex: !!root.assetsModel
                          ? TokenSelectorPanel.Tabs.Assets
                          : TokenSelectorPanel.Tabs.Collectibles

            StatusTabButton {
                text: qsTr("Assets")
                width: implicitWidth

                visible: !!root.assetsModel
            }

            StatusTabButton {
                text: qsTr("Collectibles")
                width: implicitWidth

                visible: !!root.collectiblesModel
            }
        }

        StackLayout {
            Layout.maximumHeight: 400

            visible: !!root.assetsModel || !!root.collectiblesModel
            currentIndex: tabBar.currentIndex

            ColumnLayout {
                Layout.preferredHeight: visible ? implicitHeight : 0
                spacing: 0

                Search {
                    id: assetsSearchBox

                    Layout.fillWidth: true
                    placeholderText: qsTr("Search assets")
                }

                StatusDialogDivider {
                    Layout.fillWidth: true
                    visible: assetsListView.count
                }

                StatusListView {
                    id: assetsListView

                    clip: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: contentHeight

                    model: assetsSfpm

                    delegate: TokenSelectorAssetDelegate {
                        required property var model
                        required property int index

                        highlighted: tokensKey === root.highlightedKey

                        tokensKey: model.tokensKey
                        name: model.name
                        symbol: model.symbol
                        currencyBalanceAsString: model.currencyBalanceAsString
                        iconSource: model.iconSource
                        balancesModel: model.balances

                        onClicked: root.assetSelected(model.tokensKey)
                    }
                }
            }

            StackView {
                id: collectiblesStackView

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: visible ? currentItem.implicitHeight : 0

                initialItem: ColumnLayout {
                    spacing: 0

                    Search {
                        id: collectiblesSearchBox

                        Layout.fillWidth: true
                        placeholderText: qsTr("Search collectibles")
                    }

                    StatusDialogDivider {
                        Layout.fillWidth: true
                        visible: collectiblesListView.count
                    }

                    StatusListView {
                        id: collectiblesListView

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: contentHeight

                        clip: true
                        model: collectiblesSfpm

                        delegate: TokenSelectorCollectibleDelegate {
                            required property var model

                            readonly property int subitemsCount:
                                model.subitems.ModelCount.count

                            readonly property bool isCommunity:
                                model.type === "community"

                            readonly property bool showCount:
                                subitemsCount > 1 || isCommunity

                            name: model.groupName
                            balance: showCount ? subitemsCount : ""
                            image: model.icon
                            goDeeperIconVisible: subitemsCount > 1
                                                 || isCommunity
                            highlighted: subitemsCount === 1 && !isCommunity
                                         ? ModelUtils.get(model.subitems, 0, "key")
                                           === root.highlightedKey
                                         : false

                            onClicked: {
                                if (subitemsCount === 1 && !isCommunity) {
                                    const key = ModelUtils.get(model.subitems, 0, "key")
                                    root.collectibleSelected(key)
                                    return
                                }

                                const parameters = {
                                    index: collectiblesSfpm.index(model.index, 0),
                                    model: model.subitems,
                                    isCommunity: isCommunity
                                }

                                collectiblesStackView.push(
                                            collectiblesSublistComponent,
                                            parameters,
                                            StackView.Immediate)
                            }
                        }

                        section.property: "type"
                        section.delegate: StatusBaseText {
                            color: Theme.palette.baseColor1
                            topPadding: Style.current.padding

                            text: section === "community"
                                  ? qsTr("Community minted")
                                  : qsTr("Other")
                        }
                    }
                }
            }
        }
    }

    Component {
        id: collectiblesSublistComponent

        ColumnLayout {
            property var index
            property alias model: sublistSfpm.sourceModel
            property bool isCommunity

            spacing: 0

            SortFilterProxyModel {
                id: sublistSfpm

                filters: SearchFilter {
                    roleName: "name"
                    searchPhrase: collectiblesSublistSearchBox.text
                }
            }

            StatusIconTextButton {
                id: backButton

                statusIcon: "previous"
                icon.width: 12
                icon.height: 12
                text: qsTr("Back")

                onClicked: collectiblesStackView.pop(StackView.Immediate)
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                visible: collectiblesListView.count
            }

            Search {
                id: collectiblesSublistSearchBox

                Layout.fillWidth: true
                placeholderText: qsTr("Search collectibles")
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                visible: collectiblesListView.count
            }

            StatusListView {
                id: sublist

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: contentHeight

                model: sublistSfpm

                clip: true

                delegate: TokenSelectorCollectibleDelegate {
                    required property var model

                    name: model.name
                    balance: model.balance > 1 ? model.balance : ""
                    image: model.icon
                    goDeeperIconVisible: false
                    highlighted: model.key === root.highlightedKey

                    onClicked: {
                        if (isCommunity)
                            root.collectionSelected(model.key)
                        else
                            root.collectibleSelected(model.key)
                    }
                }
            }

            // Detection if the related model entry has been removed.
            // Using model.Component.destruction.connect is not reliable because
            // is not called for submodels maintained in c++ by the parent model.
            ItemSelectionModel {
                id: selection

                model: collectiblesSfpm

                onHasSelectionChanged: {
                    if (!hasSelection)
                        collectiblesStackView.pop(StackView.Immediate)
                }

                Component.onCompleted: select(index, ItemSelectionModel.Select)
            }
        }
    }
}
