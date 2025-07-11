import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Profile.views.wallet

import Storybook

import Models

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils

import utils

SplitView {
    Logs { id: logs }


    QtObject {
        id: d

        property var timer: Timer {
            interval: 1000
            onTriggered: {
                let state  = checkbox.checked ? EditNetworkForm.Verified: EditNetworkForm.InvalidURL
                networkModule.urlVerified(networkModule.url, state)
            }
        }
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
            EditNetworkView {
                width: 560
                network: ModelUtils.get(NetworksModel.flatNetworks, 0)
                rpcProviders: d.rpcProviders
                onEvaluateRpcEndPoint: networkModule.evaluateRpcEndPoint(url)
                networksModule: networkModule
                onUpdateNetworkValues: console.error(String("Updated network with chainId %1 with new main rpc url = %2 and faalback rpc =%3").arg(chainId).arg(newMainRpcInput).arg(newFailoverRpcUrl))
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: childrenRect.height

            logsView.logText: logs.logText

            CheckBox {
                id: checkbox
                text: "valid url"
                checked: true
            }
        }
    }
}

// category: Views
