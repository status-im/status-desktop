import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core

import utils

ColumnLayout {
    id: root

    property var accountSettings

    StatusBaseText {
        text: qsTr("Default DApp explorer")
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
