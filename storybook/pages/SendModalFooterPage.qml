import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1

import Storybook 1.0

import AppLayouts.Wallet.views 1.0

SplitView {
    orientation: Qt.Vertical
    Logs { id: logs }

    Rectangle {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        color: Theme.palette.indirectColor1

        SendModalFooter {
            id: footer
            anchors.centerIn: parent
            width: 595

            loading: loadingCheckbox.checked

            onReviewSendClicked: console.log("review send clicked")
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Column {
            CheckBox {
                id: loadingCheckbox
                text: "loading"
            }

            Button {
                text: "set fees values"
                onClicked: {
                    loadingCheckbox.checked = false
                    footer.estimateTime = "~60s"
                    footer.estimatedFees = "1.45 EUR"
                }
            }
        }
    }
}

// category: Views
