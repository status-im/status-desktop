import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1

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

    /** Expected model structure: see SearchableAssetsPanel::model **/
    property alias assetsModel: searchableAssetsPanel.model

    /** Expected model structure: see SearchableCollectiblesPanel::model **/
    property alias collectiblesModel: searchableCollectiblesPanel.model

    // Index of the current tab, indexes ​​correspond to the Tabs enum values.
    property alias currentTab: tabBar.currentIndex

    signal assetSelected(string key)
    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    property string highlightedKey: ""

    function clear() {
        searchableAssetsPanel.clearSearch()
        searchableCollectiblesPanel.clearSearch()
    }

    contentItem: ColumnLayout {
        StatusTabBar {
            id: tabBar

            objectName: "tokensTabBar"

            Layout.fillWidth: true
            visible: !!root.assetsModel && !!root.collectiblesModel

            currentIndex: !!root.collectiblesModel && !root.assetsModel
                          ? TokenSelectorPanel.Tabs.Collectibles
                          : TokenSelectorPanel.Tabs.Assets

            StatusTabButton {
                objectName: "assetsTab"

                text: qsTr("Assets")
                width: implicitWidth

                visible: !!root.assetsModel
            }

            StatusTabButton {
                objectName: "collectiblesTab"
                
                text: qsTr("Collectibles")
                width: implicitWidth

                visible: !!root.collectiblesModel
            }
        }

        SearchableAssetsPanel {
            id: searchableAssetsPanel

            visible: tabBar.currentIndex === TokenSelectorPanel.Tabs.Assets
                     && !!root.assetsModel
            Layout.fillWidth: true
            Layout.fillHeight: true

            highlightedKey: root.highlightedKey

            onSelected: root.assetSelected(key)
        }

        SearchableCollectiblesPanel {
            id: searchableCollectiblesPanel

            visible: tabBar.currentIndex === TokenSelectorPanel.Tabs.Collectibles
                     && !!root.collectiblesModel
            Layout.fillWidth: true
            Layout.fillHeight: true

            highlightedKey: root.highlightedKey

            onCollectibleSelected: root.collectibleSelected(key)
            onCollectionSelected: root.collectionSelected(key)
        }
    }
}
