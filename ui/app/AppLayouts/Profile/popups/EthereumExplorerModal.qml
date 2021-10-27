import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import "../../../../shared/controls"
import "../../../../shared/popups"

// TODO: replace with StatusModal
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

        RadioButtonSelector {
            //% "None"
            title: qsTrId("none")
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
                }
            }
        }

        RadioButtonSelector {
            title: "etherscan.io"
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
                }
            }
        }

        RadioButtonSelector {
            title: "ethplorer.io"
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
                }
            }
        }

        RadioButtonSelector {
            title: "blockchair.com"
            buttonGroup: searchEnginGroup
            checked: appSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
            onCheckedChanged: {
                if (checked) {
                    appSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
                }
            }
        }
    }
}

