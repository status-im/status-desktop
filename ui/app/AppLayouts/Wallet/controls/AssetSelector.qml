import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

Control {
    id: root

    /** Expected model structure: see SearchableAssetsPanel::model **/
    property alias assetsModel: searchableAssetsPanel.model

    readonly property bool isTokenSelected: d.isTokenSelected

    signal assetSelected(string key)

    function setCustom(name: string, icon: url, key: string) {
        d.isTokenSelected = true
        tokenSelectorButton.name = name
        tokenSelectorButton.icon = icon
        searchableAssetsPanel.highlightedKey = key ?? ""
    }

    QtObject {
        id: d

        property bool isTokenSelected: false
    }

    contentItem: TokenSelectorButton {
        id: tokenSelectorButton

        selected: d.isTokenSelected
        forceHovered: dropdown.opened

        text: qsTr("Select asset")

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown

        y: parent.height + 4

        closePolicy: Popup.CloseOnPressOutsideParent
        padding: 0

        contentItem: SearchableAssetsPanel {
            id: searchableAssetsPanel

            function setCurrentAndClose(name, icon) {
                tokenSelectorButton.name = name
                tokenSelectorButton.icon = icon
                d.isTokenSelected = true
                dropdown.close()
            }

            onSelected: {
                const entry = ModelUtils.getByKey(assetsModel, "tokensKey", key)
                highlightedKey = key

                setCurrentAndClose(entry.symbol, entry.iconSource)
                root.assetSelected(key)
            }
        }
    }
}
