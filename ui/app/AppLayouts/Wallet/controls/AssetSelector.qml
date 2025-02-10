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

            onSelected: {
                const entry = ModelUtils.getByKey(root.model, "tokensKey", key)
                highlightedKey = key

                setCurrentAndClose(entry.symbol, entry.iconSource)
                root.selected(key)
            }
        }

        onClosed: searchableAssetsPanel.clearSearch()
    }
}
