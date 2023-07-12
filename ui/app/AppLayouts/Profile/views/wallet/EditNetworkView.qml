import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1

import utils 1.0

import "../../views"

ColumnLayout {
    id: root

    property var networksModule
    property var combinedNetwork

    signal evaluateRpcEndPoint(string url)
    signal updateNetworkValues(int chainId, string newMainRpcInput, string newFailoverRpcUrl)

    StatusTabBar {
        id: editPreviwTabBar
        StatusTabButton {
            text: qsTr("Live Network")
            width: implicitWidth
        }
        StatusTabButton {
            text: qsTr("Test Network")
            width: implicitWidth
        }
    }

    StackLayout {
        id: stackLayout
        Layout.preferredHeight: currentIndex === 0 ? editLiveNetwork.height: editTestNetwork.height
        Layout.fillWidth: true
        currentIndex: editPreviwTabBar.currentIndex

        EditNetworkForm {
            id: editLiveNetwork
            network: !!root.combinedNetwork ? root.combinedNetwork.prod: null
            networksModule: root.networksModule
            onEvaluateRpcEndPoint: root.evaluateRpcEndPoint(url)
            onUpdateNetworkValues: root.updateNetworkValues(chainId, newMainRpcInput, newFailoverRpcUrl)
        }

        EditNetworkForm {
            id: editTestNetwork
            network: !!root.combinedNetwork ? root.combinedNetwork.test: null
            networksModule: root.networksModule
            onEvaluateRpcEndPoint: root.evaluateRpcEndPoint(url)
            onUpdateNetworkValues: root.updateNetworkValues(chainId, newMainRpcInput, newFailoverRpcUrl)
        }
    }
}
