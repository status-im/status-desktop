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
                text: qsTr("Search engine used in the address bar")
                currentValue: {
                    switch (localAccountSensitiveSettings.shouldShowBrowserSearchEngine) {
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
                            if (localAccountSensitiveSettings.shouldShowFavoritesBar !== checked) {
                                localAccountSensitiveSettings.shouldShowFavoritesBar = checked
                            }
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

            Rectangle {
                width: parent.width
                implicitHeight: col1.height + 2 * Style.current.padding
                visible: root.store.walletStore.dappList.count === 0
                radius: Constants.settingsSection.radius
                color: Theme.palette.baseColor4

                ColumnLayout {
                    id: col1
                    width: parent.width - 2 * (Style.current.padding + Style.current.xlPadding)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Constants.settingsSection.infoSpacing

                    StatusBaseText {
                        Layout.preferredWidth: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("No connected dApps")
                        font.pixelSize: 15
                        lineHeight: Constants.settingsSection.infoLineHeight
                        lineHeightMode: Text.FixedHeight
                        color: Theme.palette.baseColor1
                    }

                    StatusBaseText {
                        Layout.preferredWidth: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Connecting a dApp grants it permission to view your address and balances,"+
                                   " and to send you transaction requests")
                        lineHeight: Constants.settingsSection.infoLineHeight
                        lineHeightMode: Text.FixedHeight
                        color: Theme.palette.baseColor1
                        wrapMode: Text.WordWrap
                    }
                }
            }

            PermissionsListView {
                id: permissionListView
                walletStore: root.store.walletStore
                visible: root.store.walletStore.dappList.count > 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
            }
        } // Column
    } // Item
} // ScrollView
