import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

Control {
    id: root

    /** Expected model structure: see SearchableAssetsPanel::model **/
    property alias model: searchableAssetsPanel.model

    property alias sectionProperty: searchableAssetsPanel.sectionProperty

    readonly property bool isSelected: button.selected

    signal selected(string key)

    function setCustom(name: string, symbol: string, icon: url, key: string) {
        button.name = name
        button.subname = symbol
        button.icon = icon
        button.selected = true

        searchableAssetsPanel.highlightedKey = key ?? ""
    }

    function reset() {
        button.selected = false
    }

    contentItem: TokenSelectorCompactButton {
        id: button

        objectName: "assetSelectorButton"

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown

        y: parent.height + 4
        width: parent.width

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
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
    }
}
