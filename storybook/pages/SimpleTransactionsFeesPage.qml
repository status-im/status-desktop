import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import Storybook

import AppLayouts.Wallet.panels

SplitView {
    orientation: Qt.Vertical

    Rectangle {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        color: Theme.palette.baseColor3

        SimpleTransactionsFees {
            anchors.centerIn: parent
            width: 400

            cryptoFees: qsTr("0.0007 ETH")
            fiatFees: qsTr("1.45 EUR")
            loading: loadingCheckbox.checked
            error: errorCheckbox.checked
            networkName: "Mainnet"
        }
    }

    Pane {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        ColumnLayout {
            CheckBox {
                id: loadingCheckbox
                text: "loading"
            }

            CheckBox {
                id: errorCheckbox
                text: "error"
            }
        }
    }
}

// category: Views
