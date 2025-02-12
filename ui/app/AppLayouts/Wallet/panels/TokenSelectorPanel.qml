import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0  // Import required for Settings

import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

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

    property bool showSectionName: true

    signal assetSelected(string key)
    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    property string highlightedKey: ""

    function clear() {
        searchableAssetsPanel.clearSearch()
        searchableCollectiblesPanel.clearSearch()
    }

    Settings {
        id: lastTabSettings
        readonly property int lastSelectedTab: tabBar.currentIndex
    }

    contentItem: ColumnLayout {
        spacing: 0
        StatusTabBar {
            id: tabBar

            objectName: "tokensTabBar"

            Layout.fillWidth: true
            visible: !!root.assetsModel && !!root.collectiblesModel

            currentIndex: !!root.collectiblesModel && !root.assetsModel
                          ? TokenSelectorPanel.Tabs.Collectibles
                          : lastTabSettings.lastSelectedTab

            StatusTabButton {
                objectName: "assetsTab"

                text: qsTr("Assets")
                width: visible ? implicitWidth : 0
                leftPadding: visible ? Theme.padding : 0

                visible: !!root.assetsModel
            }

            StatusTabButton {
                objectName: "collectiblesTab"
                
                text: qsTr("Collectibles")
                width: implicitWidth

                visible: !!root.collectiblesModel
            }
        }

        StatusDialogDivider {
            Layout.topMargin: -9
            Layout.fillWidth: true
        }

        SearchableAssetsPanel {
            id: searchableAssetsPanel

            visible: tabBar.currentIndex === TokenSelectorPanel.Tabs.Assets
                     && !!root.assetsModel
            Layout.fillWidth: true
            Layout.fillHeight: true

            highlightedKey: root.highlightedKey
            showSectionName: root.showSectionName

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
