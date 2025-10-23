import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtWebChannel

import StatusQ.Core.Theme
import utils

/**
 * ConnectorBridge
 * 
 * Simplified connector infrastructure for BrowserLayout.
 * Provides WebEngine profiles with script injection, WebChannel, 
 * ConnectorManager, and direct connection to Nim backend.
 * 
 * This component bridges the Browser UI with the Connector backend system.
 */
Item {
    id: root

    // Properties
    property string userUID: ""
    property var connectorController: null
    property string defaultAccountAddress: ""  // Default wallet account address
    property var accountsModel: null           // Model of all available accounts
    property string httpUserAgent: ""          // Custom user agent for web profiles

    // Expose profiles and channel
    readonly property alias webChannel: channel
    readonly property alias defaultProfile: defaultProfile
    readonly property alias otrProfile: otrProfile
    
    // Expose manager for external URL updates
    readonly property alias manager: connectorManager
    
    // Expose dApp metadata properties for direct binding
    property alias dappUrl: connectorManager.dappUrl
    property alias dappOrigin: connectorManager.dappOrigin
    property alias dappName: connectorManager.dappName
    property alias dappIconUrl: connectorManager.dappIconUrl
    property alias clientId: connectorManager.clientId
    
    // Helper functions (replaces web3ProviderStore functions)
    function hasWalletConnected(hostname, address) {
        if (!connectorController) return false
        // Check if dApp has permission via connector
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
        if (!connectorController) return false
        return connectorController.disconnect(hostname)
    }
    
    // Function to update dApp metadata from external source
    function updateDAppUrl(url, name) {
        if (!url) return
        
        const urlStr = url.toString()
        connectorManager.dappUrl = urlStr
        connectorManager.dappOrigin = urlStr
        connectorManager.dappName = name || extractDomainName(urlStr)
        connectorManager.dappChainId = 1  // Default to Mainnet
        
        console.log("[ConnectorBridge] Updated dApp metadata:")
        console.log("[ConnectorBridge]  - URL:", urlStr)
        console.log("[ConnectorBridge]  - Name:", connectorManager.dappName)
        console.log("[ConnectorBridge]  - ChainId:", connectorManager.dappChainId)
    }
    
    // Helper to extract domain name from URL
    function extractDomainName(urlString) {
        try {
            const urlObj = new URL(urlString)
            return urlObj.hostname || "Unknown dApp"
        } catch (e) {
            return "Unknown dApp"
        }
    }

    // Helper function to create script config
    function createScript(scriptName, runOnSubframes = true) {
        return {
            name: scriptName,
            sourceUrl: Qt.resolvedUrl("../js/" + scriptName),
            injectionPoint: WebEngineScript.DocumentCreation,
            worldId: WebEngineScript.MainWorld,
            runOnSubframes: runOnSubframes
        }
    }

    // Script injection collection
    readonly property var _scripts: [
        createScript("qwebchannel.js", true),
        createScript("ethereum_wrapper.js", true),
        createScript("eip6963_announcer.js", false), // Only top-level window (EIP-6963 spec)
        createScript("ethereum_injector.js", true)
    ]

    // Web Engine Profiles with connector script injection
    WebEngineProfile {
        id: defaultProfile
        storageName: "Profile_%1".arg(root.userUID)
        offTheRecord: false
        httpUserAgent: root.httpUserAgent
        userScripts.collection: root._scripts
    }

    WebEngineProfile {
        id: otrProfile
        storageName: "IncognitoProfile_%1".arg(root.userUID)
        offTheRecord: true
        persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
        httpUserAgent: root.httpUserAgent
        userScripts.collection: root._scripts
    }

    // ConnectorManager - Business Logic with direct Nim connection
    ConnectorManager {
        id: connectorManager
        connectorController: root.connectorController  // (shared_modules/connector/controller.nim)
        
        dappUrl: ""
        dappOrigin: ""
        dappName: ""
        dappIconUrl: ""
        dappChainId: 1
        clientId: "status-desktop/dapp-browser"

        // Forward events to Eip1193ProviderAdapter
        onConnectEvent: (info) => eip1193ProviderAdapter.connectEvent(info)
        onAccountsChangedEvent: (accounts) => eip1193ProviderAdapter.accountsChangedEvent(accounts)
        onChainChangedEvent: (chainId) => eip1193ProviderAdapter.chainChangedEvent(chainId)
        onRequestCompletedEvent: (payload) => eip1193ProviderAdapter.requestCompletedEvent(payload)
        onDisconnectEvent: (error) => eip1193ProviderAdapter.disconnectEvent(error)
        onMessageEvent: (message) => eip1193ProviderAdapter.messageEvent(message)
    }

    WebChannel {
        id: channel
        registeredObjects: [eip1193ProviderAdapter]
    }

    Eip1193ProviderAdapter {
        id: eip1193ProviderAdapter
        WebChannel.id: "ethereumProvider"
        chainId: connectorManager.dappChainId
        accounts: connectorManager.accounts

        function request(args) {
            return connectorManager.request(args)
        }
    }
}

