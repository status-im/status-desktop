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

ScrollView {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property ProfileSectionStore store
    property real profileContentWidth

    property Component searchEngineModal: SearchEngineModal {}

    contentHeight: rootItem.height

    Item {
        id: rootItem
        width: parent.width
        height: childrenRect.height

        Column {
            id: layout
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 48
            width: profileContentWidth
            spacing: 10
            StatusBaseText {
                id: titleText
                text: qsTr("Browser")
                font.weight: Font.Bold
                font.pixelSize: 28
                color: Theme.palette.directColor1
            }

            Item {
                height: 25
                width: 1
            }

            HomePageView {
                id: homePageView
                homepage: localAccountSensitiveSettings.browserHomepage
            }

            // TODO: Replace with StatusQ StatusListItem component
            StatusSettingsLineButton {
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
            }

            StatusListItem {
                id: showFavouritesItem
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width + Style.current.padding * 2
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
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
            }

            StatusBaseText {
                text: qsTr("Connected DApps")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }

            PermissionsListView {
                id: permissionListView
                width: parent.width
                walletStore: root.store.walletStore
            }
        } // Column
    } // Item
} // ScrollView
