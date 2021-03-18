import QtQuick 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "Privileges/"
import "BrowserModals"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    property Component dappListPopup: DappList {
        onClosed: destroy()
    }
    property Component homePagePopup: HomepageModal {}
    property Component searchEngineModal: SearchEngineModal {}
    property Component ethereumExplorerModal: EthereumExplorerModal {}

    Item {
        anchors.top: parent.top
        anchors.topMargin: topMargin
        anchors.bottom: parent.bottom
        width: contentMaxWidth
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            id: generalColumn
            width: parent.width

            StatusSectionHeadline {
                //% "General"
                text: qsTrId("general")
                bottomPadding: Style.current.bigPadding
            }

            StatusSettingsLineButton {
                //% "Homepage"
                text: qsTrId("homepage")
                //% "Default"
                currentValue: appSettings.browserHomepage === "" ? qsTrId("default") : appSettings.browserHomepage
                onClicked: homePagePopup.createObject(root).open()
            }

            StatusSettingsLineButton {
                //% "Show favorites bar"
                text: qsTrId("show-favorites-bar")
                isSwitch: true
                switchChecked: appSettings.shouldShowFavoritesBar
                onClicked: function (checked) {
                    appSettings.shouldShowFavoritesBar = checked
                }
            }

            StatusSettingsLineButton {
                //% "Search engine used in the address bar"
                text: qsTrId("search-engine-used-in-the-address-bar")
                currentValue: {
                    switch (appSettings.shouldShowBrowserSearchEngine) {
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

            StatusSettingsLineButton {
                id: ethereumExplorerBtn
                //% "Ethereum explorer used in the address bar"
                text: qsTrId("ethereum-explorer-used-in-the-address-bar")
                currentValue: {
                    switch (appSettings.useBrowserEthereumExplorer) {
                    case Constants.browserEthereumExplorerEtherscan: return "etherscan.io"
                    case Constants.browserEthereumExplorerEthplorer: return "ethplorer.io"
                    case Constants.browserEthereumExplorerBlockchair: return "blockchair.com"
                    case Constants.browserSearchEngineNone:
                    //% "None"
                    default: return qsTrId("none")
                    }
                }
                onClicked: ethereumExplorerModal.createObject(root).open()
            }
            StyledText {
                //% "Open an ethereum explorer after a transaction hash or an address is entered"
                text: qsTrId("open-an-ethereum-explorer-after-a-transaction-hash-or-an-address-is-entered")
                font.pixelSize: 15
                color: Style.current.secondaryText
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

            StatusSettingsLineButton {
                //% "Set DApp access permissions"
                text: qsTrId("set-dapp-access-permissions")
                isSwitch: false
                onClicked: {
                    dappListPopup.createObject(root).open()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
