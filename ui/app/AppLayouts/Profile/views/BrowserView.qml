import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import utils
import shared
import shared.panels
import shared.status

import "../popups"
import "browser"

SettingsContentBase {
    id: root

    property var accountSettings

    property Component searchEngineModal: SearchEngineModal {
        accountSettings: root.accountSettings
    }

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
                accountSettings: root.accountSettings
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
            }

            StatusSettingsLineButton {
                width: parent.width
                text: qsTr("Search engine used in the address bar")
                currentValue: {
                    switch (accountSettings.shouldShowBrowserSearchEngine) {
                    case Constants.browserSearchEngineGoogle: return "Google"
                    case Constants.browserSearchEngineYahoo: return "Yahoo!"
                    case Constants.browserSearchEngineDuckDuckGo: return "DuckDuckGo"
                    case Constants.browserSearchEngineNone:
                    default: return qsTr("None")
                    }
                }
                onClicked: searchEngineModal.createObject(root).open()
            }

            DefaultDAppExplorerView {
                id: dAppExplorerView
                accountSettings: root.accountSettings
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
            }

            StatusListItem {
                id: showFavouritesItem
                width: parent.width
                title: qsTr("Show Favorites Bar")
                components: [
                    StatusSwitch {
                        id: favSwitch
                        checked: accountSettings.shouldShowFavoritesBar
                        onToggled: { accountSettings.shouldShowFavoritesBar = checked }
                    }
                ]
                onClicked: accountSettings.shouldShowFavoritesBar = !accountSettings.shouldShowFavoritesBar
            }

            OpenLinksInView {
                accountSettings: root.accountSettings
            }
        }
    }
}
