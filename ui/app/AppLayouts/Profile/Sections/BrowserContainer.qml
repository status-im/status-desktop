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

    Column {
        id: generalColumn
        spacing: Style.current.bigPadding
        anchors.top: parent.top
        anchors.topMargin: 46
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.right: parent.right
        anchors.rightMargin: contentMargin

        StatusSectionHeadline {
            text: qsTr("General")
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

        Item {
            width: parent.width
            height: childrenRect.height

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
                anchors.top: ethereumExplorerBtn.bottom
                anchors.topMargin: 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 150
                wrapMode: Text.WordWrap
            }
        }

        // TODO redd this when we figure out how to set the download path for the browser
//        Separator {}

//        StatusSectionHeadline {
//            text: qsTr("Downloads")
//        }


//        Item {
//            height: textItem.height
//            width: parent.width

//            StyledText {
//                id: textItem
//                text: qsTr("Location")
//                font.pixelSize: 15
//            }

//            StyledText {
//                id: valueText
//                text: "path/to/downloads"
//                font.pixelSize: 15
//                color: Style.current.secondaryText
//                anchors.right: locationBtn.left
//                anchors.rightMargin: Style.current.halfPadding
//                anchors.verticalCenter: textItem.verticalCenter
//            }

//            StatusButton {
//                id: locationBtn
//                text: qsTr("Change")
//                anchors.right: parent.right
//                anchors.verticalCenter: textItem.verticalCenter
//                onClicked: {
//                    console.log('change location')
//                }
//            }
//        }

        Separator {}

        StatusSectionHeadline {
            text: qsTr("Privacy")
        }

        StatusSettingsLineButton {
            text: qsTr("Set DApp access permissions")
            onClicked: dappListPopup.createObject(root).open()
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
