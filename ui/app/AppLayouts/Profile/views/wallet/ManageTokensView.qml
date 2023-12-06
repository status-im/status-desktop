import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1

import shared.controls 1.0
import utils 1.0

import AppLayouts.Profile.panels 1.0
import AppLayouts.Wallet.panels 1.0

ColumnLayout {
    id: root

    required property var sourcesOfTokensModel // Expected roles: key, name, updatedAt, source, version, tokensCount, image
    required property var tokensListModel // Expected roles: name, symbol, image, chainName, explorerUrl

    required property var baseWalletAssetsModel
    required property var baseWalletCollectiblesModel

    property alias currentIndex: tabBar.currentIndex

    readonly property bool dirty: {
        if (!loader.item)
            return false
        if (tabBar.currentIndex > d.collectiblesTabIndex)
            return false
        if (tabBar.currentIndex === d.collectiblesTabIndex && baseWalletCollectiblesModel.isFetching)
            return false
        return loader.item && loader.item.dirty
    }

    function saveChanges() {
        if (tabBar.currentIndex > d.collectiblesTabIndex)
            return
        loader.item.saveSettings()
    }

    function resetChanges() {
        if (tabBar.currentIndex > d.collectiblesTabIndex)
            return
        loader.item.revert()
    }

    QtObject {
        id: d

        readonly property int assetsTabIndex: 0
        readonly property int collectiblesTabIndex: 1
        readonly property int tokenSourcesTabIndex: 2

        function checkLoadMoreCollectibles() {
            if (tabBar.currentIndex !== collectiblesTabIndex)
                return
            // If there is no more items to load or we're already fetching, return
            if (!root.baseWalletCollectiblesModel.hasMore || root.baseWalletCollectiblesModel.isFetching)
                return
            root.baseWalletCollectiblesModel.loadMore()
        }
    }

    Connections {
        target: root.baseWalletCollectiblesModel
        function onHasMoreChanged() {
            d.checkLoadMoreCollectibles()
        }
        function onIsFetchingChanged() {
            d.checkLoadMoreCollectibles()
        }
    }

    StatusTabBar {
        id: tabBar

        Layout.fillWidth: true
        Layout.topMargin: 5

        StatusTabButton {
            leftPadding: 0
            width: implicitWidth
            text: qsTr("Assets")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Collectibles")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Token lists")
        }
    }

    // NB: we want to discard any pending unsaved changes when switching tabs or navigating away
    Loader {
        id: loader
        Layout.fillWidth: true
        Layout.fillHeight: true
        active: visible

        sourceComponent: {
            switch (tabBar.currentIndex) {
            case d.assetsTabIndex:
                return tokensPanel
            case d.collectiblesTabIndex:
                return collectiblesPanel
            case d.tokenSourcesTabIndex:
                return supportedTokensListPanel
            }
        }
    }

    Component {
        id: tokensPanel
        ManageAssetsPanel {
            baseModel: root.baseWalletAssetsModel
        }
        // TODO #12611 add Advanced section
    }

    Component {
        id: collectiblesPanel
        ManageCollectiblesPanel {
            baseModel: root.baseWalletCollectiblesModel
            Component.onCompleted: d.checkLoadMoreCollectibles()
        }
    }

    Component {
        id: supportedTokensListPanel
        SupportedTokenListsPanel {
            sourcesOfTokensModel: root.sourcesOfTokensModel
            tokensListModel: root.tokensListModel
        }
    }
}
