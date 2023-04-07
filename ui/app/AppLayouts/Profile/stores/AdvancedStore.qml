import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    property var advancedModule

    // Advanced Module Properties
    property string fleet: advancedModule? advancedModule.fleet : ""
    property string bloomLevel: advancedModule? advancedModule.bloomLevel : ""
    property bool wakuV2LightClientEnabled: advancedModule? advancedModule.wakuV2LightClientEnabled : false
    property bool isTelemetryEnabled: advancedModule? advancedModule.isTelemetryEnabled : false
    property bool isAutoMessageEnabled: advancedModule? advancedModule.isAutoMessageEnabled : false
    property bool isDebugEnabled: advancedModule? advancedModule.isDebugEnabled : false
    property bool isWakuV2StoreEnabled: advancedModule ? advancedModule.isWakuV2StoreEnabled : false
    property int logMaxBackups: advancedModule ? advancedModule.logMaxBackups : 1

    property var customNetworksModel: advancedModule? advancedModule.customNetworksModel : []

    property bool isWakuV2: root.fleet === Constants.waku_prod   ||
                            root.fleet === Constants.waku_test   ||
                            root.fleet === Constants.status_test ||
                            root.fleet === Constants.status_prod

    readonly property bool isFakeLoadingScreenEnabled: localAppSettings.fakeLoadingScreenEnabled ?? false
    readonly property QtObject experimentalFeatures: QtObject {
        readonly property string browser: "browser"
        readonly property string communities: "communities"
        readonly property string activityCenter: "activityCenter"
        readonly property string nodeManagement: "nodeManagement"
        readonly property string onlineUsers: "onlineUsers"
        readonly property string gifWidget: "gifWidget"
        readonly property string communitiesPortal: "communitiesPortal"
        readonly property string communityPermissions: "communityPermissions"
        readonly property string discordImportTool: "discordImportTool"
        readonly property string wakuV2StoreEnabled: "wakuV2StoreEnabled"
        readonly property string communityTokens: "communityTokens"
    }

    readonly property bool isCustomScrollingEnabled: localAppSettings.isCustomMouseScrollingEnabled ?? false
    readonly property real scrollVelocity: localAppSettings.scrollVelocity
    readonly property real scrollDeceleration: localAppSettings.scrollDeceleration

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

    function setMaxLogBackups(value) {
        if(!root.advancedModule)
            return

        root.advancedModule.setMaxLogBackups(value)
    }

    function enableDeveloperFeatures() {
        if(!root.advancedModule)
            return

        root.advancedModule.enableDeveloperFeatures()
    }

    function toggleExperimentalFeature(feature) {
        if(!root.advancedModule)
            return

        if (feature === experimentalFeatures.browser) {
            advancedModule.toggleBrowserSection()
        }
        else if (feature === experimentalFeatures.communities) {
            advancedModule.toggleCommunitySection()
        }
        else if (feature === experimentalFeatures.communitiesPortal) {
            advancedModule.toggleCommunitiesPortalSection()
        }
        else if (feature === experimentalFeatures.wakuV2StoreEnabled) {
            // toggle history archive support
            advancedModule.toggleWakuV2Store()
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
    }

    function toggleFakeLoadingScreen() {
        if(!localAppSettings)
            return

        localAppSettings.fakeLoadingScreenEnabled = !localAppSettings.fakeLoadingScreenEnabled
    }

    function setCustomScrollingEnabled(value) {
        if(!localAppSettings)
            return

        localAppSettings.isCustomMouseScrollingEnabled = value
    }

    function setScrollVelocity(value) {
        if(!localAppSettings)
            return

        localAppSettings.scrollVelocity = value
    }

    function setScrollDeceleration(value) {
        if(!localAppSettings)
            return

        localAppSettings.scrollDeceleration = value
    }
}
