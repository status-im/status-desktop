import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

Control {
    id: root

    /** Expected model structure: see SearchableAssetsPanel::model **/
    property alias assetsModel: tokenSelectorPanel.assetsModel

    /** Expected model structure: see SearchableCollectiblesPanel::model **/
    property alias collectiblesModel: tokenSelectorPanel.collectiblesModel

    /** Exposes insatnce of popup **/
    property var popup: dropdown

    /** Sets size of the TokenSelectorButton **/
    property alias size: tokenSelectorButton.size

    readonly property bool isTokenSelected: tokenSelectorButton.selected

    signal assetSelected(string key)
    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    // Index of the current tab, indexes ​​correspond to the
    // TokensSelectorPanel.Tabs enum values.
    property alias currentTab: tokenSelectorPanel.currentTab

    function setSelection(name: string, icon: url, key: string) {
        // reset token selector in case of empty call
        if (!key && !name && !icon) {
            tokenSelectorButton.selected = false
        } else {
            tokenSelectorButton.selected = true
            tokenSelectorButton.name = name
            tokenSelectorButton.icon = icon
            tokenSelectorPanel.highlightedKey = key ?? ""
        }
    }

    QObject {
        id: d

        readonly property int maxPopupHeight: 330
    }

    contentItem: TokenSelectorButton {
        id: tokenSelectorButton

        forceHovered: dropdown.opened

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown

        y: parent.height + 4
        width: 448

        horizontalPadding: 0
        bottomPadding: 0

        onClosed: tokenSelectorPanel.clear()

        contentItem: Item {
            implicitHeight: Math.min(tokenSelectorPanel.implicitHeight, d.maxPopupHeight)

            TokenSelectorPanel {
                id: tokenSelectorPanel

                objectName: "tokenSelectorPanel"

                anchors.fill: parent

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
                    tokenSelectorButton.name = name
                    tokenSelectorButton.icon = icon
                    tokenSelectorButton.selected = true
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
}
