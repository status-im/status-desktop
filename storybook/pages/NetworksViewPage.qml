import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views.wallet 1.0

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import Models 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    QtObject {
        id: d

        property var networksModel: NetworksModel.flatNetworks
    }

    property var networkModule: QtObject {
        id: networkModule
        signal urlVerified(string url, int status)
        property string url

        function evaluateRpcEndPoint(url, isMainUrl) {
            networkModule.url = url
            d.timer.restart()
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ScrollView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            NetworksView {
                width: 560
                flatNetworks: d.networksModel
                areTestNetworksEnabled: testModeCheckBox.checked

                onEditNetwork: {
                    console.log("Edit network", chainId)
                }
                onSetNetworkActive: {
                    console.log("Set network active test networks", chainId, active)
                    const index = ModelUtils.indexOf(d.networksModel, "chainId", chainId)
                    d.networksModel.setProperty(index, "isActive", active)
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: childrenRect.height

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            spacing: 16

            CheckBox {
                id: testModeCheckBox
                text: "Testnet mode"
                checked: false
            }
        }
    }
}

// category: Views
