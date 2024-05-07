import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1

import utils 1.0

import "../../views"

ColumnLayout {
    id: root

    property var networksModule
    property var combinedNetwork
    property var networkRPCChanged
    property bool areTestNetworksEnabled: false

    signal evaluateRpcEndPoint(string url, bool isMainUrl)
    signal updateNetworkValues(int chainId, bool testNetwork, string newMainRpcInput, string newFailoverRpcUrl, bool revertToDefault)

    onVisibleChanged: {
        if (visible)
            editPreviwTabBar.currentIndex = root.areTestNetworksEnabled ? 1 : 0
    }

    StatusTabBar {
        id: editPreviwTabBar
        objectName: "editPreviwTabBar"
        StatusTabButton {
            leftPadding: 0
            text: qsTr("Live Network")
            objectName: "editNetworkLiveButton"
            width: implicitWidth
        }
        StatusTabButton {
            text: qsTr("Test Network")
            objectName: "editNetworkTestButton"
            width: implicitWidth
        }
    }

    Loader {
        objectName: "editNetworkLoader"
        Layout.fillWidth: true
        active: root.visible
        sourceComponent: editPreviwTabBar.currentIndex === 0 ? editLiveNetwork: editTestNetwork
    }

    Component {
        id: editLiveNetwork
        EditNetworkForm {
            network: !!root.combinedNetwork ? root.combinedNetwork.prod: null
            networksModule: root.networksModule
            networkRPCChanged: root.networkRPCChanged
            onEvaluateRpcEndPoint: root.evaluateRpcEndPoint(url, isMainUrl)
            onUpdateNetworkValues: root.updateNetworkValues(chainId, false, newMainRpcInput, newFailoverRpcUrl, revertToDefault)
        }
    }

    Component {
        id: editTestNetwork
        EditNetworkForm {
            network: !!root.combinedNetwork ? root.combinedNetwork.test: null
            networksModule: root.networksModule
            networkRPCChanged: root.networkRPCChanged
            onEvaluateRpcEndPoint: root.evaluateRpcEndPoint(url, isMainUrl)
            onUpdateNetworkValues: root.updateNetworkValues(chainId, true, newMainRpcInput, newFailoverRpcUrl, revertToDefault)
        }
    }
}
