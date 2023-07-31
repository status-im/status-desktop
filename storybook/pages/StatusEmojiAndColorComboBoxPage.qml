import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0

SplitView {
    id: root

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        ColumnLayout {
            anchors.margins: 100
            anchors.fill: parent
            spacing: 150

            StatusEmojiAndColorComboBox {
                Layout.preferredWidth: 300
                model: WalletAccountsModel {}
                type: StatusComboBox.Type.Secondary
                size: StatusComboBox.Size.Small
                implicitHeight: 44
                defaultAssetName: "filled-account"
            }

            StatusEmojiAndColorComboBox {
                Layout.preferredWidth: 300
                model: WalletAccountsModel {}
            }

            // filler
            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Components
