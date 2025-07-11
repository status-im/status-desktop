import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import Storybook
import utils

import shared.controls

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
