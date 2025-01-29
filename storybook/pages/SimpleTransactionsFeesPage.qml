import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1

import Storybook 1.0

import AppLayouts.Wallet.panels 1.0

SplitView {
    orientation: Qt.Vertical

    Rectangle {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        color: Theme.palette.baseColor3

        SimpleTransactionsFees {
            anchors.centerIn: parent
            width: 400

            cryptoFees: cryptoFees.text
            fiatFees: fiatFees.text
            loading: loadingCheckbox.checked
            error: errorCheckbox.checked
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
            TextField {
                id: cryptoFees
                text: "0.0007 ETH"
            }
            TextField {
                id: fiatFees
                text:"1.45 EUR"
            }
        }
    }
}

// category: Views
