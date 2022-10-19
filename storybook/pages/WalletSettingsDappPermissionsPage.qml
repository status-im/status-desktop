import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        DappPermissionsView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            dappList: ListModel {
                ListElement {
                    name: "Dapp 1"
                    accounts: []
                    color: "#ffffff"
                    emoji: ""
                    address: "0x123"
                }
            }

            onDisconnect: (dappName) => {
                logs.logEvent("walletStore::disconnect", ["dappName"], arguments)
            }
            onDisconnectAddress: (dappName, address) => {
                logs.logEvent("walletStore::disconnectAddress", ["dappName", "address"], arguments)
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

