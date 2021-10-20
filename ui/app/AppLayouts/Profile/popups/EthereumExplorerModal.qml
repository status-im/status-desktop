import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

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

        StatusRadioButtonRow {
            //% "None"
            text: qsTrId("none")
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
                }
            }
        }

        StatusRadioButtonRow {
            text: "etherscan.io"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
                }
            }
        }

        StatusRadioButtonRow {
            text: "ethplorer.io"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
                }
            }
        }

        StatusRadioButtonRow {
            text: "blockchair.com"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
                }
            }
        }
    }
}

