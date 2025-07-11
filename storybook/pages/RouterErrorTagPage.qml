import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import Storybook

import utils

import AppLayouts.Wallet.controls

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
