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
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.bottom: parent.bottom

        Column {
            id: generalColumn
            width: parent.width

            StatusSectionHeadline {
                text: qsTr("General")
                bottomPadding: Style.current.bigPadding
            }

            StatusSettingsLineButton {
                text: qsTr("Homepage")
                currentValue: appSettings.browserHomepage === "" ? qsTr("Default") : appSettings.browserHomepage
                onClicked: homePagePopup.createObject(root).open()
            }

            StatusSettingsLineButton {
                text: qsTr("Show favorites bar")
                isSwitch: true
                switchChecked: appSettings.showFavoritesBar
                onClicked: function (checked) {
                    appSettings.showFavoritesBar = checked
                }
            }

            StatusSettingsLineButton {
                text: qsTr("Search engine used in the address bar")
                currentValue: {
                    switch (appSettings.browserSearchEngine) {
                    case Constants.browserSearchEngineGoogle: return "Google"
                    case Constants.browserSearchEngineYahoo: return "Yahoo!"
                    case Constants.browserSearchEngineDuckDuckGo: return "DuckDuckGo"
                    case Constants.browserSearchEngineNone:
                    default: return qsTr("None")
                    }
                }
                onClicked: searchEngineModal.createObject(root).open()
            }

            StatusSettingsLineButton {
                id: ethereumExplorerBtn
                text: qsTr("Ethereum explorer used in the address bar")
                currentValue: {
                    switch (appSettings.browserEthereumExplorer) {
                    case Constants.browserEthereumExplorerEtherscan: return "etherscan.io"
                    case Constants.browserEthereumExplorerEthplorer: return "ethplorer.io"
                    case Constants.browserEthereumExplorerBlockchair: return "blockchair.com"
                    case Constants.browserSearchEngineNone:
                    default: return qsTr("None")
                    }
                }
                onClicked: ethereumExplorerModal.createObject(root).open()
            }
            StyledText {
                text: qsTr("Open an ethereum explorer after a transaction hash or an address is entered")
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
                text: qsTr("Privacy")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            StatusSettingsLineButton {
                text: qsTr("Set DApp access permissions")
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
