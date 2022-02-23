import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var advancedModule

    // Advanced Module Properties
    property string currentNetworkName: advancedModule? advancedModule.currentNetworkName : ""
    property string currentNetworkId: advancedModule? advancedModule.currentNetworkId : ""
    property string fleet: advancedModule? advancedModule.fleet : ""
    property string bloomLevel: advancedModule? advancedModule.bloomLevel : ""
    property bool wakuV2LightClientEnabled: advancedModule? advancedModule.wakuV2LightClientEnabled : false
    property bool isTelemetryEnabled: advancedModule? advancedModule.isTelemetryEnabled : false
    property bool isAutoMessageEnabled: advancedModule? advancedModule.isAutoMessageEnabled : false
    property bool isDebugEnabled: advancedModule? advancedModule.isDebugEnabled : false

    property var customNetworksModel: advancedModule? advancedModule.customNetworksModel : []

    property bool isWakuV2: root.fleet === Constants.waku_prod ||
                            root.fleet === Constants.waku_test ||
                            root.fleet === Constants.status_test

    readonly property QtObject experimentalFeatures: QtObject {
        readonly property string wallet: "wallet"
        readonly property string browser: "browser"
        readonly property string communities: "communities"
        readonly property string activityCenter: "activityCenter"
        readonly property string nodeManagement: "nodeManagement"
        readonly property string onlineUsers: "onlineUsers"
        readonly property string gifWidget: "gifWidget"
        readonly property string keycard: "keycard"
        readonly property string multiNetwork: "multiNetwork"
    }

    function setGlobalNetworkId() {
        Global.currentNetworkId = currentNetworkId
    }
    Component.onCompleted: {
        setGlobalNetworkId()
    }
    onCurrentNetworkIdChanged: {
        setGlobalNetworkId()
    }

    function logDir() {
        if(!root.advancedModule)
            return ""

        return root.advancedModule.logDir()
    }

    function setNetworkName(networkName) {
        if(!root.advancedModule)
            return

        root.advancedModule.setNetworkName(networkName)
    }

    function setFleet(fleetName) {
        if(!root.advancedModule)
            return

        root.advancedModule.setFleet(fleetName)
    }

    function setBloomLevel(mode) {
        if(!root.advancedModule)
            return

        root.advancedModule.setBloomLevel(mode)
    }

    function setWakuV2LightClientEnabled(mode) {
        if(!root.advancedModule)
            return

        root.advancedModule.setWakuV2LightClientEnabled(mode)
    }

    function toggleTelemetry() {
        if(!root.advancedModule)
            return

        root.advancedModule.toggleTelemetry()
    }

    function toggleAutoMessage() {
        if(!root.advancedModule)
            return

        root.advancedModule.toggleAutoMessage()
    }

    function toggleDebug() {
        if(!root.advancedModule)
            return

        root.advancedModule.toggleDebug()
    }

    function enableDeveloperFeatures() {
        if(!root.advancedModule)
            return

        root.advancedModule.enableDeveloperFeatures()
    }

    function addCustomNetwork(name, endpoint, networkId, networkType) {
        if(!root.advancedModule)
            return

        root.advancedModule.addCustomNetwork(name, endpoint, networkId, networkType)
    }

    function toggleExperimentalFeature(feature) {
        if(!root.advancedModule)
            return

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
        else if (feature === experimentalFeatures.multiNetwork) {
            localAccountSensitiveSettings.isMultiNetworkEnabled = !localAccountSensitiveSettings.isMultiNetworkEnabled
        }
    }
}
