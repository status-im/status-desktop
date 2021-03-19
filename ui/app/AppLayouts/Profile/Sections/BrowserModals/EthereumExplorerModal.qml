import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    id: popup

    //% "Ethereum explorer"
    title: qsTrId("ethereum-explorer")

    onClosed: {
        destroy()
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        ButtonGroup {
            id: searchEnginGroup
        }

        StatusRadioButtonRow {
            //% "None"
            text: qsTrId("none")
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
                }
            }
        }

        StatusRadioButtonRow {
            text: "etherscan.io"
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
                }
            }
        }

        StatusRadioButtonRow {
            text: "ethplorer.io"
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
                }
            }
        }

        StatusRadioButtonRow {
            text: "blockchair.com"
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
                }
            }
        }
    }
}

