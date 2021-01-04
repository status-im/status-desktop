import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    id: popup

    title: qsTr("Ethereum explorer")

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
            text: qsTr("None")
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.browserEthereumExplorer === Constants.browserEthereumExplorerNone
            onCheckedChanged: {
                if (checked) {
                    appSettings.browserEthereumExplorer = Constants.browserEthereumExplorerNone
                }
            }
        }

        StatusRadioButton {
            text: "etherscan.io"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.browserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
            onCheckedChanged: {
                if (checked) {
                    appSettings.browserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
                }
            }
        }

        StatusRadioButton {
            text: "ethplorer.io"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.browserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
            onCheckedChanged: {
                if (checked) {
                    appSettings.browserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
                }
            }
        }

        StatusRadioButton {
            text: "blockchair.com"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.browserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
            onCheckedChanged: {
                if (checked) {
                    appSettings.browserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
                }
            }
        }
    }
}

