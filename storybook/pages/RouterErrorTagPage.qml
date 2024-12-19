import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import Storybook 1.0

import utils 1.0

import AppLayouts.Wallet.controls 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Rectangle {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        color: Theme.palette.baseColor3
        RouterErrorTag {
            anchors.centerIn: parent
            width: 400

            errorTitle: ctrlText.text
            buttonText: ctrlButtonText.text
            errorDetails: ctrlErrorDetails.text
            expandable: expandableCheckBox.checked
        }
    }

    Pane {
        ColumnLayout {
            CheckBox {
                id: expandableCheckBox
                text: "expandable"
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Text:" }
                TextField {
                    id: ctrlText
                    Layout.fillWidth: true
                    text: "Not enough ETH to pay gas fees"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Button text:" }
                TextField {
                    id: ctrlButtonText
                    Layout.fillWidth: true
                    text: "Add ETH"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Asset name:" }
                TextField {
                    id: ctrlAssetName
                    Layout.fillWidth: true
                    text: "warning"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Error Details:" }
                TextField {
                    id: ctrlErrorDetails
                    Layout.fillWidth: true
                    text: "Error Details will be displayed here"
                }
            }
        }
    }
}

// category: Views
