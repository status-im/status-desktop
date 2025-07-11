import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Profile.views.wallet

import StatusQ
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Utils

import Models

import Storybook

import utils

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
