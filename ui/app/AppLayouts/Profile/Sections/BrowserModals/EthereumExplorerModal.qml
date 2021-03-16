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
        spacing: Style.current.bigPadding
        width: parent.width

        ButtonGroup {
            id: searchEnginGroup
        }

        StatusRadioButton {
            //% "None"
            text: qsTrId("none")
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
                }
            }
        }

        StatusRadioButton {
            text: "etherscan.io"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
                }
            }
        }

        StatusRadioButton {
            text: "ethplorer.io"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
                }
            }
        }

        StatusRadioButton {
            text: "blockchair.com"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
                }
            }
        }
    }
}

