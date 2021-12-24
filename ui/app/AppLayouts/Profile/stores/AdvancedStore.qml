import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var advancedModule

    // Advanced Module Properties
    property string currentNetworkName: advancedModule.currentNetworkName
    property string currentNetworkId: advancedModule.currentNetworkId
    property string fleet: advancedModule.fleet
    property string bloomLevel: advancedModule.bloomLevel
    property bool wakuV2LightClientEnabled: advancedModule.wakuV2LightClientEnabled
    property bool isTelemetryEnabled: advancedModule.isTelemetryEnabled
    property bool isAutoMessageEnabled: advancedModule.isAutoMessageEnabled
    property bool isDebugEnabled: advancedModule.isDebugEnabled

    property var customNetworksModel: advancedModule.customNetworksModel

    property bool isWakuV2: root.fleet === Constants.waku_prod ||
                            root.fleet === Constants.waku_test

    readonly property QtObject experimentalFeatures: QtObject {
        readonly property string wallet: "wallet"
        readonly property string browser: "browser"
        readonly property string communities: "communities"
        readonly property string activityCenter: "activityCenter"
        readonly property string nodeManagement: "nodeManagement"
        readonly property string onlineUsers: "onlineUsers"
        readonly property string gifWidget: "gifWidget"
        readonly property string keycard: "keycard"
    }

    function logDir() {
        return root.advancedModule.logDir()
    }

    function setNetworkName(networkName) {
        root.advancedModule.setNetworkName(networkName)
    }

    function setFleet(fleetName) {
        root.advancedModule.setFleet(fleetName)
    }

    function setBloomLevel(mode) {
        root.advancedModule.setBloomLevel(mode)
    }

    function setWakuV2LightClientEnabled(mode) {
        root.advancedModule.setWakuV2LightClientEnabled(mode)
    }

    function toggleTelemetry() {
        root.advancedModule.toggleTelemetry()
    }

    function toggleAutoMessage() {
        root.advancedModule.toggleAutoMessage()
    }

    function toggleDebug() {
        root.advancedModule.toggleDebug()
    }

    function addCustomNetwork(name, endpoint, networkId, networkType) {
        root.advancedModule.addCustomNetwork(name, endpoint, networkId, networkType)
    }

    function toggleExperimentalFeature(feature) {
        if (feature === experimentalFeatures.wallet) {
            advancedModule.toggleWalletSection()
        }
        else if (feature === experimentalFeatures.browser) {
            advancedModule.toggleBrowserSection()
        }
        else if (feature === experimentalFeatures.communities) {
            advancedModule.toggleCommunitySection()
        }
        else if (feature === experimentalFeatures.activityCenter) {
            localAccountSensitiveSettings.isActivityCenterEnabled = !localAccountSensitiveSettings.isActivityCenterEnabled
        }
        else if (feature === experimentalFeatures.nodeManagement) {
            advancedModule.toggleNodeManagementSection()
        }
        else if (feature === experimentalFeatures.onlineUsers) {
            localAccountSensitiveSettings.showOnlineUsers = !localAccountSensitiveSettings.showOnlineUsers
        }
        else if (feature === experimentalFeatures.gifWidget) {
            localAccountSensitiveSettings.isGifWidgetEnabled = !localAccountSensitiveSettings.isGifWidgetEnabled
        }
        else if (feature === experimentalFeatures.keycard) {
            localAccountSettings.isKeycardEnabled = !localAccountSettings.isKeycardEnabled
        }
    }
}
