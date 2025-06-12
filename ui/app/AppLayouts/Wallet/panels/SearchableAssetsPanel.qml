import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.views 1.0

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

/**
  Panel holding search field and lists of assets.
*/
Control {
    id: root

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
        sectionName (optional)  [string] - text to be rendered as a section
    **/
    property alias model: sfpm.sourceModel
    property string highlightedKey
    property string nonInteractiveKey
    property bool showSectionName: true

    signal selected(string key)

    function clearSearch() {
        searchBox.text = ""
    }

    QtObject {
        id: d
        readonly property bool validSearchResultExists: !!searchBox.text && sfpm.count > 0
    }

    SortFilterProxyModel {
        id: sfpm

        filters: AnyOf {
            SearchFilter {
                roleName: "name"
                searchPhrase: searchBox.text
            }
            SearchFilter {
                roleName: "symbol"
                searchPhrase: searchBox.text
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            text: qsTr("Your assets will appear here")
            color: Theme.palette.baseColor1
            visible: !listView.count && !searchBox.text
        }

        TokenSearchBox {
            id: searchBox

            objectName: "searchBox"

            Layout.fillWidth: true
            placeholderText: qsTr("Search for token or enter token address")

            visible: listView.count || !!searchBox.text

            Keys.forwardTo: [listView]
        }

        StatusDialogDivider {
            Layout.fillWidth: true
            visible: listView.count
        }

        StatusListView {
            id: listView

            objectName: "assetsListView"

            clip: true

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: contentHeight
            Layout.leftMargin: 4
            Layout.rightMargin: 4

            spacing: 4

            model: sfpm.ModelCount.count > 0 ? sfpm : null
            section.property: "sectionName"

            section.delegate: TokenSelectorSectionDelegate {
                width: ListView.view.width
                text: section
                height: root.showSectionName ? implicitHeight : 0
            }

            delegate: TokenSelectorAssetDelegate {
                required property var model
                required property int index

                width: ListView.view.width

                highlighted: model.tokensKey === root.highlightedKey
                enabled: model.tokensKey !== root.nonInteractiveKey
                balancesListInteractive: !ListView.view.moving
                isAutoHovered: d.validSearchResultExists && index === 0 && !listViewHoverHandler.hovered

                name: model.name
                symbol: model.symbol
                currencyBalanceAsString: model.currencyBalanceAsString ?? ""
                iconSource: model.iconSource
                balancesModel: model.balances

                onClicked: root.selected(model.tokensKey)
            }

            Keys.onReturnPressed: {
                if(d.validSearchResultExists)
                    listView.itemAtIndex(0).clicked()
            }

            Keys.onEnterPressed: {
                if(d.validSearchResultExists)
                    listView.itemAtIndex(0).clicked()
            }

            HoverHandler {
                id: listViewHoverHandler
            }
        }
    }
}
