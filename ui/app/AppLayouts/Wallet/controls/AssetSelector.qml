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
    property alias nonInteractiveKey: searchableAssetsPanel.nonInteractiveKey

    readonly property bool isSelected: button.selected

    signal selected(string key)

    function setSelection(name: string, icon: url, key: string) {
        button.name = name
        button.icon = icon
        button.selected = true

        searchableAssetsPanel.highlightedKey = key ?? ""
    }

    function reset() {
        button.selected = false
        searchableAssetsPanel.highlightedKey = ""
    }

    contentItem: TokenSelectorButton {
        id: button

        objectName: "tokenSelectorButton"

        forceHovered: dropdown.opened
        text: qsTr("Select asset")

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown

        objectName: "dropdown"

        y: root.height + 4
        x: root.width - width

        width: 448

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        padding: 0

        contentItem: SearchableAssetsPanel {
            id: searchableAssetsPanel

            objectName: "searchableAssetsPanel"

            function setCurrentAndClose(name, icon) {
                button.name = name
                button.icon = icon
                button.selected = true
                dropdown.close()
            }

            onSelected: function(key) {
                const entry = ModelUtils.getByKey(root.model, "tokensKey", key)
                highlightedKey = key

                setCurrentAndClose(entry.symbol, entry.iconSource)
                root.selected(key)
            }
        }

        onClosed: searchableAssetsPanel.clearSearch()
    }
}
