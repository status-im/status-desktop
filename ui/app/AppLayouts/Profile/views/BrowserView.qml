import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import "../popups"
import "../stores"
import "browser"
import "wallet"

SettingsContentBase {
    id: root

    property ProfileSectionStore store

    property Component searchEngineModal: SearchEngineModal {}

    Item {
        id: rootItem
        width: root.contentWidth
        height: childrenRect.height

        Column {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            spacing: 10

            HomePageView {
                id: homePageView
                homepage: localAccountSensitiveSettings.browserHomepage
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
            }

            // TODO: Replace with StatusQ StatusListItem component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                //% "Search engine used in the address bar"
                text: qsTrId("search-engine-used-in-the-address-bar")
                currentValue: {
                    switch (localAccountSensitiveSettings.shouldShowBrowserSearchEngine) {
                    case Constants.browserSearchEngineGoogle: return "Google"
                    case Constants.browserSearchEngineYahoo: return "Yahoo!"
                    case Constants.browserSearchEngineDuckDuckGo: return "DuckDuckGo"
                    case Constants.browserSearchEngineNone:
                        //% "None"
                    default: return qsTrId("none")
                    }
                }
                onClicked: searchEngineModal.createObject(root).open()
            }

            DefaultDAppExplorerView {
                id: dAppExplorerView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
            }

            StatusListItem {
                id: showFavouritesItem
                width: parent.width
                title: qsTr("Show Favorites Bar")
                components: [
                    StatusSwitch {
                        checked: localAccountSensitiveSettings.shouldShowFavoritesBar
                        onCheckedChanged: {
                            localAccountSensitiveSettings.shouldShowFavoritesBar = checked
                        }
                    }
                ]
            }

            Separator {
                id: separator1
                width: parent.width
            }

            StatusBaseText {
                text: qsTr("Connected DApps")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
            }

            PermissionsListView {
                id: permissionListView
                walletStore: root.store.walletStore
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
            }
        } // Column
    } // Item
} // ScrollView
