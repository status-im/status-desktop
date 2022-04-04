import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    StatusBaseText {
        text: qsTr("Default DApp explorer")
        font.pixelSize: 15
        color: Theme.palette.directColor1
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
        checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerNone
        text: qsTr("none")
        onCheckedChanged: {
            if (checked) {
                localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerNone
            }
        }
    }

    StatusRadioButton {
        id: etherscanRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEtherscan
        text: "etherscan.io"
        onCheckedChanged: {
            if (checked && localAccountSensitiveSettings.useBrowserEthereumExplorer !== Constants.browserEthereumExplorerEtherscan) {
                localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEtherscan
            }
        }
    }

    StatusRadioButton {
        id: ethplorerRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerEthplorer
        text: "ethplorer.io"
        onCheckedChanged: {
            if (checked) {
                localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerEthplorer
            }
        }
    }

    StatusRadioButton {
        id: blockchairRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: localAccountSensitiveSettings.useBrowserEthereumExplorer === Constants.browserEthereumExplorerBlockchair
        text: "blockchair.com"
        onCheckedChanged: {
            if (checked) {
                localAccountSensitiveSettings.useBrowserEthereumExplorer = Constants.browserEthereumExplorerBlockchair
            }
        }
    }

} // Column
