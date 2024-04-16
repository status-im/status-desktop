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
            locale: Qt.locale(ctrlLocaleName.text)
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
                    text: "Valid:\t"
                }
                Label {
                    Layout.fillWidth: true
                    font.bold: true
                    text: input.valid ? "true" : "false"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Locale:\t"
                }
                TextField {
                    id: ctrlLocaleName
                    placeholderText: "Default locale: %1".arg(input.locale.name)
                }
            }
        }
    }
}

// category: Controls

// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=305-139866&mode=design&t=g49O9LFh8PkuPxZB-0
