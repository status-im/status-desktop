import QtQuick
import QtQuick.Controls

import StatusQ.Controls
import StatusQ.Core.Utils

import AppLayouts.Wallet.panels

import utils

Control {
    id: root

    /** Expected model structure: see SearchableAssetsPanel::model **/
    property alias model: searchableAssetsPanel.model

    readonly property bool isSelected: button.selected

    signal selected(string key)

    function setSelection(name: string, symbol: string, icon: url, key: string) {
        button.name = name
        button.subname = symbol
        button.icon = icon
        button.selected = true

        searchableAssetsPanel.highlightedKey = key ?? ""
    }

    function reset() {
        button.selected = false
        searchableAssetsPanel.highlightedKey = ""
    }

    contentItem: TokenSelectorCompactButton {
        id: button

        objectName: "assetSelectorButton"

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown

        directParent: root
        relativeY: root.height + 4
        width: root.width

        bottomSheetAllowed: false

        padding: 0

        contentItem: SearchableAssetsPanel {
            id: searchableAssetsPanel

            function setCurrentAndClose(name, symbol, icon) {
                button.name = name
                button.subname = symbol
                button.icon = icon
                button.selected = true

                dropdown.close()
            }

            onSelected: {
                const entry = ModelUtils.getByKey(root.model, "tokensKey", key)
                highlightedKey = key

                setCurrentAndClose(entry.name, entry.symbol, entry.iconSource)
                root.selected(key)
            }
        }

        onClosed: searchableAssetsPanel.clearSearch()
    }
}
