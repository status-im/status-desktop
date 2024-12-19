import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml.Models 2.15

import StatusQ.Core.Theme 0.1

import Storybook 1.0

import AppLayouts.Wallet.views 1.0
import AppLayouts.Wallet.controls 1.0

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
            error: errorCheckbox.checked

            onReviewSendClicked: logs.logEvent("review send clicked")

            errorTags: errorCheckbox.checked ? errorTagsModel: null
        }
    }

    ObjectModel {
        id: errorTagsModel
        RouterErrorTag {
            errorTitle: "Error 1"
            buttonText: "Add ETH"
        }
        RouterErrorTag {
            errorTitle: "Error 2"
            buttonText: "Add ETH"
            errorDetails: "Details will appear here"
            expandable: true
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

            CheckBox {
                id: errorCheckbox
                text: "error"
            }

            Button {
                text: "set fees values"
                onClicked: {
                    loadingCheckbox.checked = false
                    footer.estimatedTime = "~60s"
                    footer.estimatedFees = "1.45 EUR"
                }
            }
        }
    }
}

// category: Views
