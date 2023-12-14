import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    property var advancedModule
    property var walletModule
    property var networksModule: root.walletModule.networksModule

    // Advanced Module Properties
    property string fleet: advancedModule? advancedModule.fleet : ""
    property string bloomLevel: advancedModule? advancedModule.bloomLevel : ""
    property bool wakuV2LightClientEnabled: advancedModule? advancedModule.wakuV2LightClientEnabled : false
    property bool isTelemetryEnabled: advancedModule? advancedModule.isTelemetryEnabled : false
    property bool isAutoMessageEnabled: advancedModule? advancedModule.isAutoMessageEnabled : false
    property bool isDebugEnabled: advancedModule? advancedModule.isDebugEnabled : false
    readonly property bool isWakuV2ShardedCommunitiesEnabled: localAppSettings.wakuV2ShardedCommunitiesEnabled ?? false
    property int logMaxBackups: advancedModule ? advancedModule.logMaxBackups : 1

    property var customNetworksModel: advancedModule? advancedModule.customNetworksModel : []

    property bool isWakuV2: root.fleet === Constants.waku_prod   ||
                            root.fleet === Constants.waku_test   ||
                            root.fleet === Constants.status_test ||
                            root.fleet === Constants.status_prod ||
                            root.fleet === Constants.shards_test

    readonly property bool isFakeLoadingScreenEnabled: localAppSettings.fakeLoadingScreenEnabled ?? false
    property bool isManageCommunityOnTestModeEnabled: false
    readonly property QtObject experimentalFeatures: QtObject {
        readonly property string browser: "browser"
        readonly property string communities: "communities"
        readonly property string activityCenter: "activityCenter"
        readonly property string nodeManagement: "nodeManagement"
        readonly property string onlineUsers: "onlineUsers"
        readonly property string communitiesPortal: "communitiesPortal"
        readonly property string communityPermissions: "communityPermissions"
        readonly property string discordImportTool: "discordImportTool"
        readonly property string communityTokens: "communityTokens"
    }

    readonly property bool isCustomScrollingEnabled: localAppSettings.isCustomMouseScrollingEnabled ?? false
    readonly property real scrollVelocity: localAppSettings.scrollVelocity
    readonly property real scrollDeceleration: localAppSettings.scrollDeceleration

    readonly property bool isSepoliaEnabled: networksModule.isSepoliaEnabled

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
        else if (feature === experimentalFeatures.activityCenter) {
            localAccountSensitiveSettings.isActivityCenterEnabled = !localAccountSensitiveSettings.isActivityCenterEnabled
        }
        else if (feature === experimentalFeatures.nodeManagement) {
            advancedModule.toggleNodeManagementSection()
        }
        else if (feature === experimentalFeatures.onlineUsers) {
            localAccountSensitiveSettings.showOnlineUsers = !localAccountSensitiveSettings.showOnlineUsers
        }
    }

    function toggleFakeLoadingScreen() {
        if(!localAppSettings)
            return

        localAppSettings.fakeLoadingScreenEnabled = !localAppSettings.fakeLoadingScreenEnabled
    }

    function toggleManageCommunityOnTestnet() {
        root.isManageCommunityOnTestModeEnabled = !root.isManageCommunityOnTestModeEnabled
    }

    function toggleWakuV2ShardedCommunities() {
        if(!localAppSettings)
            return

        localAppSettings.wakuV2ShardedCommunitiesEnabled = !localAppSettings.wakuV2ShardedCommunitiesEnabled
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

    function toggleIsSepoliaEnabled(){
        networksModule.toggleIsSepoliaEnabled()
    }

}
