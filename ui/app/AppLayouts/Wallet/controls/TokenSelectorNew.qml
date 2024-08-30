import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

Control {
    id: root

    /** Expected model structure: see TokenSelectorPanel::assetsModel **/
    property alias assetsModel: tokenSelectorPanel.assetsModel

    /** Expected model structure: see TokenSelectorPanel::collectiblesModel **/
    property alias collectiblesModel: tokenSelectorPanel.collectiblesModel

    readonly property bool isTokenSelected: d.isTokenSelected

    signal assetSelected(string key)
    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    // Index of the current tab, indexes ​​correspond to the
    // TokensSelectorPanel.Tabs enum values.
    property alias currentTab: tokenSelectorPanel.currentTab

    function setCustom(name: string, icon: url, key: string) {
        d.isTokenSelected = true
        d.currentName = name
        d.currentIcon = icon
        tokenSelectorPanel.highlightedKey = key ?? ""
    }

    QtObject {
        id: d

        property bool isTokenSelected: false

        property string currentName
        property url currentIcon
    }

    contentItem: TokenSelectorButton {
        selected: d.isTokenSelected
        forceHovered: dropdown.opened

        name: d.currentName
        icon: d.currentIcon

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown

        y: parent.height + 4

        closePolicy: Popup.CloseOnPressOutsideParent
        bottomPadding: 0

        contentItem: TokenSelectorPanel {
            id: tokenSelectorPanel

            objectName: "tokenSelectorPanel"

            function findSubitem(key) {
                const count = collectiblesModel.rowCount()

                for (let i = 0; i < count; i++) {
                    const entry = ModelUtils.get(collectiblesModel, i)
                    const subitem = ModelUtils.getByKey(
                                      entry.subitems, "key", key)
                    if (subitem)
                        return subitem
                }
            }

            function setCurrentAndClose(name, icon) {
                d.currentName = name
                d.currentIcon = icon
                d.isTokenSelected = true
                dropdown.close()
            }

            onAssetSelected: {
                const entry = ModelUtils.getByKey(assetsModel, "tokensKey", key)
                highlightedKey = key

                setCurrentAndClose(entry.symbol, entry.iconSource)
                root.assetSelected(key)
            }

            onCollectibleSelected: {
                highlightedKey = key

                const subitem = findSubitem(key)
                setCurrentAndClose(subitem.name, subitem.icon)

                root.collectibleSelected(key)
            }

            onCollectionSelected: {
                highlightedKey = key

                const subitem = findSubitem(key)
                setCurrentAndClose(subitem.name, subitem.icon)

                root.collectionSelected(key)
            }
        }
    }
}
