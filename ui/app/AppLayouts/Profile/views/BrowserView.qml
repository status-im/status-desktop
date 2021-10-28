import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.status 1.0

import "../popups"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property var store

    property Component dappListPopup: DappList {
        store: root.store
        onClosed: destroy()
    }
    property Component homePagePopup: HomepageModal {}
    property Component searchEngineModal: SearchEngineModal {}
    property Component ethereumExplorerModal: EthereumExplorerModal {}

    Item {
        anchors.top: parent.top
        anchors.topMargin: 64
        anchors.bottom: parent.bottom
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            id: generalColumn
            width: parent.width

            StatusSectionHeadline {
                //% "General"
                text: qsTrId("general")
                bottomPadding: Style.current.bigPadding
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Homepage")
                label: localAccountSensitiveSettings.browserHomepage === "" ? qsTrId("default") : localAccountSensitiveSettings.browserHomepage
                onClicked: homePagePopup.createObject(root).open()
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Show favorites bar")

                onClicked: favoritesBarSwitch.checked = !favoritesBarSwitch.checked
                components: [
                    StatusSwitch {
                        id: favoritesBarSwitch
                        checked: !localAccountSensitiveSettings.shouldShowFavoritesBar
                        onClicked: {
                            localAccountSensitiveSettings.shouldShowFavoritesBar = checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
                //% "Search engine used in the address bar"
                title: qsTrId("search-engine-used-in-the-address-bar")
                label: {
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
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
                //% "Ethereum explorer used in the address bar"
                title: qsTrId("ethereum-explorer-used-in-the-address-bar")
                label: {
                    switch (localAccountSensitiveSettings.useBrowserEthereumExplorer) {
                        case Constants.browserEthereumExplorerEtherscan: return "etherscan.io"
                        case Constants.browserEthereumExplorerEthplorer: return "ethplorer.io"
                        case Constants.browserEthereumExplorerBlockchair: return "blockchair.com"
                        case Constants.browserSearchEngineNone:
                        //% "None"
                        default: return qsTrId("none")
                    }
                }
                onClicked: ethereumExplorerModal.createObject(root).open()
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }
            StatusBaseText {
                //% "Open an ethereum explorer after a transaction hash or an address is entered"
                text: qsTrId("open-an-ethereum-explorer-after-a-transaction-hash-or-an-address-is-entered")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                width: parent.width - 150
                wrapMode: Text.WordWrap
                bottomPadding: Style.current.bigPadding
            }

            Separator {
                id: separator1
                anchors.topMargin: Style.current.bigPadding
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
            }

            StatusSectionHeadline {
                //% "Privacy"
                text: qsTrId("privacy")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
                //% "Set DApp access permissions"
                title: qsTrId("set-dapp-access-permissions")
                onClicked: dappListPopup.createObject(root).open()
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
