import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme

import utils

ColumnLayout {
    id: root

    property var accountSettings

    StatusBaseText {
        Layout.fillWidth: true
        text: qsTr("Blockchain explorer in the address bar")
        wrapMode: Text.WordWrap
    }

    StatusBaseText {
        Layout.fillWidth: true
        text: qsTr("Choose a blockchain explorer to open Ethereum addresses or transaction hashes entered in the address bar")
        color: Theme.palette.baseColor1
        wrapMode: Text.WordWrap
    }

    ButtonGroup {
        id: explorerGroup
        buttons: [
            noneRadioButton,
            etherscanRadioButton,
            ethplorerRadioButton,
            blockchairRadioButton
        ]
        exclusive: true
    }

    StatusRadioButton {
        id: noneRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: accountSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
        text: qsTr("None")
        onCheckedChanged: {
            if (checked) {
                accountSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
            }
        }
    }

    StatusRadioButton {
        id: etherscanRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: accountSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
        text: "etherscan.io"
        onCheckedChanged: {
            if (checked && accountSettings.useBrowserEthereumExplorer !== Constants.browserEthereumExplorerEtherscan) {
                accountSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
            }
        }
    }

    StatusRadioButton {
        id: ethplorerRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: accountSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
        text: "ethplorer.io"
        onCheckedChanged: {
            if (checked) {
                accountSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
            }
        }
    }

    StatusRadioButton {
        id: blockchairRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: accountSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
        text: "blockchair.com"
        onCheckedChanged: {
            if (checked) {
                accountSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
            }
        }
    }
}
