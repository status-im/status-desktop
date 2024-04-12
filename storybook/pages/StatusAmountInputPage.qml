import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import Storybook 1.0
import utils 1.0

import shared.controls 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusAmountInput {
            id: input
            anchors.centerIn: parent
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400

        SplitView.fillHeight: true

        ColumnLayout {
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Valid:"
                }
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    font.bold: true
                    text: input.valid ? "true" : "false"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Locale:"
                }
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    font.bold: true
                    text: input.locale.name
                }
            }
        }
    }
}

// category: Controls

// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=305-139866&mode=design&t=g49O9LFh8PkuPxZB-0
