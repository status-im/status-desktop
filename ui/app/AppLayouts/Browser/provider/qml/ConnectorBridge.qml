import QtQuick
import QtWebEngine
import QtWebChannel

import "Utils.js" as BrowserUtils

/**
 * ConnectorBridge
 *
 * Simplified connector infrastructure for BrowserLayout.
 * Provides WebEngine profiles with script injection, WebChannel,
 * ConnectorManager, and direct connection to Nim backend.
 *
 * This component bridges the Browser UI with the Connector backend system.
 */
QtObject {
    id: root

    required property string userUID
    required property var connectorController
    property string httpUserAgent: ""          // Custom user agent for web profiles

    property bool clearingCache: false
    signal cacheClearCompleted()

    readonly property alias dappUrl: connectorManager.dappUrl
    readonly property alias dappOrigin: connectorManager.dappOrigin
    readonly property alias dappName: connectorManager.dappName
    readonly property alias dappIconUrl: connectorManager.dappIconUrl
    readonly property alias clientId: connectorManager.clientId

    readonly property ConnectorManager connectorManager: ConnectorManager {
        id: connectorManager
        connectorController: root.connectorController  // (shared_modules/connector/controller.nim)

        // Forward events to Eip1193ProviderAdapter
        onConnectEvent: (info) => eip1193ProviderAdapter.connectEvent(info)
        onAccountsChangedEvent: (accounts) => eip1193ProviderAdapter.accountsChangedEvent(accounts)
        onChainChangedEvent: (chainId) => eip1193ProviderAdapter.chainChangedEvent(chainId)
        onRequestCompletedEvent: (payload) => eip1193ProviderAdapter.requestCompletedEvent(payload)
        onDisconnectEvent: (error) => eip1193ProviderAdapter.disconnectEvent(error)
        onMessageEvent: (message) => eip1193ProviderAdapter.messageEvent(message)
        onProviderStateChanged: () => eip1193ProviderAdapter.providerStateChanged()
    }

    readonly property Eip1193ProviderAdapter eip1193ProviderAdapter: Eip1193ProviderAdapter {
        id: eip1193Provider
        objectName: "ethereumProvider"
        WebChannel.id: "ethereumProvider"

        chainId: BrowserUtils.chainIdToHex(connectorManager.dappChainId)
        networkVersion: connectorManager.dappChainId.toString()
        selectedAddress: connectorManager.accounts.length > 0 ? connectorManager.accounts[0] : ""
        accounts: connectorManager.accounts
        connected: connectorManager.connected

        onRequestInternal: (args) => connectorManager.request(args)
    }

    readonly property SiteUtilsAdapter siteUtilsAdapter: SiteUtilsAdapter {
        id: siteUtils
        objectName: "siteUtils"
        WebChannel.id: "siteUtils"
    }

    function clearSiteDataAndReload() {
        siteUtilsAdapter.clearSiteDataAndReload()
    }

    function clearCache(profile) {
        if (clearingCache) {
            console.warn("[ConnectorBridge] Cache clearing already in progress")
            return
        }

        clearingCache = true
        profile.clearHttpCache()
        _cacheClearFallbackTimer.start()
    }

    function clearCurrentProfileCache() {
        clearCache(defaultProfile)
    }

    function _onCacheClearCompleted() {
        if (!clearingCache) return  // Already completed via fallback
        _cacheClearFallbackTimer.stop()
        clearingCache = false
        console.log("[ConnectorBridge] Cache clear completed (via signal)")
        cacheClearCompleted()
    }

    // Fallback timer in case clearHttpCacheCompleted signal doesn't fire
    readonly property Timer _cacheClearFallbackTimer: Timer {
        interval: 1000
        repeat: false
        onTriggered: {
            if (!root.clearingCache) return  // Already completed via signal
            root.clearingCache = false
            console.log("[ConnectorBridge] Cache clear completed (via fallback timer)")
            root.cacheClearCompleted()
        }
    }

    readonly property var _scripts: [
        createScript("qwebchannel.js", true),
        createScript("site_utils.js", true),
        createScript("ethereum_wrapper.js", true),
        createScript("eip6963_announcer.js", false), // Only top-level window (EIP-6963 spec)
        createScript("ethereum_injector.js", true)
    ]

    readonly property WebEngineProfile defaultProfile: WebEngineProfile {
        storageName: "Profile_%1".arg(root.userUID)
        offTheRecord: false
        httpUserAgent: root.httpUserAgent
        userScripts.collection: root._scripts
        onClearHttpCacheCompleted: root._onCacheClearCompleted()
    }

    readonly property WebEngineProfile otrProfile: WebEngineProfile {
        storageName: "IncognitoProfile_%1".arg(root.userUID)
        offTheRecord: true
        persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
        httpUserAgent: root.httpUserAgent
        userScripts.collection: root._scripts
        onClearHttpCacheCompleted: root._onCacheClearCompleted()
    }

    readonly property WebChannel channel: WebChannel {
        registeredObjects: [eip1193ProviderAdapter, siteUtilsAdapter]
    }

    function hasWalletConnected(hostname, address) {
        if (!connectorController) return false

        const dApps = connectorController.getDApps()
        try {
            const dAppsObj = JSON.parse(dApps)
            if (Array.isArray(dAppsObj)) {
                return dAppsObj.some(function(dapp) {
                    return dapp.url && dapp.url.indexOf(hostname) >= 0
                })
            }
        } catch (e) {
            console.warn("[ConnectorBridge] Error checking wallet connection:", e)
        }
        return false
    }

    function disconnect(hostname) {
        if (!connectorController) {
            return false
        }
        
        const result = connectorController.disconnect(hostname, clientId)
        return result
    }

    function disconnectCurrentTab() {
        if (!dappOrigin) {
            return false
        }
        
        return disconnect(dappOrigin)
    }

    function updateDAppUrl(url, name) {
        connectorManager.updateDAppUrl(url, name)
    }

    function createScript(scriptName, runsOnSubframes = true) {
        if (!connectorController)
            return {}
        return {
            name: scriptName,
            sourceUrl: Qt.resolvedUrl("../js/" + scriptName),
            injectionPoint: WebEngineScript.DocumentCreation,
            worldId: WebEngineScript.MainWorld,
            runsOnSubframes: runsOnSubframes
        }
    }
}
