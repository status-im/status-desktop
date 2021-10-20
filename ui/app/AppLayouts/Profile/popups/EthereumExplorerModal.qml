import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import shared.popups 1.0
import shared.controls 1.0

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
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
                }
            }
        }

        RadioButtonSelector {
            title: "etherscan.io"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
                }
            }
        }

        RadioButtonSelector {
            title: "ethplorer.io"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
                }
            }
        }

        RadioButtonSelector {
            title: "blockchair.com"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
                }
            }
        }
    }
}

