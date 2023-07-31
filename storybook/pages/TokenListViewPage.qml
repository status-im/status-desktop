import QtQuick 2.15
import QtQuick.Controls 2.15

import Models 1.0
import Storybook 1.0

import shared.views 1.0

SplitView {
    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        TokenListView {
            anchors.centerIn: parent

            width: 400

            getNetworkIcon: function(chainId) {
                return "network/Network=Optimism"
            }

            assets: WalletAssetsModel {}
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100

        SplitView.fillWidth: true
    }
}

// category: Views
