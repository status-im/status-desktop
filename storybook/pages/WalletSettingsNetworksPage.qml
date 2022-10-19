import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        NetworksView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            layer1Networks: ListModel {
                ListElement {
                    chainName: "Ethereum Mainnet"
                    iconUrl: "network/Network=Ethereum"
                }
            }

            layer2Networks: ListModel {
                ListElement {
                    chainName: "Optimism"
                    iconUrl: "network/Network=Optimism"
                }
                ListElement {
                    chainName: "Arbitrum"
                    iconUrl: "network/Network=Arbitrum"
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        // model editor will go here
    }
}

