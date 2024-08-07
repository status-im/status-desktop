import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    property var advancedModule
    property var walletModule
    property var networksModuleInst: networksModule

    // Advanced Module Properties
    property string fleet: advancedModule? advancedModule.fleet : ""
    property bool wakuV2LightClientEnabled: advancedModule? advancedModule.wakuV2LightClientEnabled : false
    property bool isTelemetryEnabled: advancedModule? advancedModule.isTelemetryEnabled : false
    property bool isAutoMessageEnabled: advancedModule? advancedModule.isAutoMessageEnabled : false
    property bool isNimbusProxyEnabled: advancedModule? advancedModule.isNimbusProxyEnabled : false
    property bool isDebugEnabled: advancedModule? advancedModule.isDebugEnabled : false
    readonly property bool isWakuV2ShardedCommunitiesEnabled: localAppSettings.wakuV2ShardedCommunitiesEnabled ?? false
    property int logMaxBackups: advancedModule ? advancedModule.logMaxBackups : 1
    property bool isRuntimeLogLevelSet: advancedModule ? advancedModule.isRuntimeLogLevelSet: false
    readonly property bool archiveProtocolEnabled: advancedModule ? advancedModule.archiveProtocolEnabled : false
    readonly property bool ensCommunityPermissionsEnabled: localAccountSensitiveSettings.ensCommunityPermissionsEnabled

    property var customNetworksModel: advancedModule? advancedModule.customNetworksModel : []

    readonly property bool isFakeLoadingScreenEnabled: localAppSettings.fakeLoadingScreenEnabled ?? false
    readonly property bool createCommunityEnabled: localAppSettings.createCommunityEnabled ?? false
    property bool isManageCommunityOnTestModeEnabled: false
    readonly property QtObject experimentalFeatures: QtObject {
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

    readonly property bool refreshTokenEnabled: localAppSettings.refreshTokenEnabled ?? false

    readonly property bool isGoerliEnabled: networksModuleInst.isGoerliEnabled

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

    function toggleNimbusProxy() {
        if(!root.advancedModule)
            return

        root.advancedModule.toggleNimbusProxy()
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

        if (feature === experimentalFeatures.communities) {
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

    function toggleCreateCommunityEnabled() {
        if(!localAppSettings)
            return

        localAppSettings.createCommunityEnabled = !localAppSettings.createCommunityEnabled
    }

    function toggleArchiveProtocolEnabled() {
        if(!advancedModule)
            return

        if (root.archiveProtocolEnabled) {
            advancedModule.disableCommunityHistoryArchiveSupport()
        } else {
            advancedModule.enableCommunityHistoryArchiveSupport()
        }
    }

    function toggleEnsCommunityPermissionsEnabled() {
        localAccountSensitiveSettings.ensCommunityPermissionsEnabled = !root.ensCommunityPermissionsEnabled
    }

    function toggleManageCommunityOnTestnet() {
        root.isManageCommunityOnTestModeEnabled = !root.isManageCommunityOnTestModeEnabled
    }

    function toggleWakuV2ShardedCommunities() {
        if(!localAppSettings)
            return

        localAppSettings.wakuV2ShardedCommunitiesEnabled = !localAppSettings.wakuV2ShardedCommunitiesEnabled
    }

    function toggleRefreshTokenEnabled() {
        if(!localAppSettings)
            return
        localAppSettings.refreshTokenEnabled = !localAppSettings.refreshTokenEnabled
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

    function toggleIsGoerliEnabled(){
        networksModule.toggleIsGoerliEnabled()
    }

}
