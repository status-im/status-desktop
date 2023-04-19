import QtQuick 2.15
import QtQuick.Controls 2.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.controls 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        id: container

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            width: 800
            height: 200
            border.width: 1
            anchors.centerIn: parent

            NetworkFilter {
                anchors.centerIn: parent
                width: 200

                layer1Networks: NetworksModel.layer1Networks
                layer2Networks: NetworksModel.layer2Networks
                testNetworks: NetworksModel.testNetworks
                enabledNetworks: NetworksModel.enabledNetworks
                allNetworks: enabledNetworks

                isChainVisible: isChainVisibleCheckBox.checked
                multiSelection: multiSelectionCheckBox.checked
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        SplitView.fillWidth: true

        Row {
            CheckBox {
                id: isChainVisibleCheckBox
                text: "Is chain visible"
                checked: true
            }
            CheckBox {
                id: multiSelectionCheckBox
                text: "Multi selection"
                checked: true
            }
        }
    }
}
