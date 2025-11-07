import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtWebChannel

import StatusQ.Core.Theme
import utils

import "Utils.js" as Utils

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

    required property string userUID
    required property var connectorController
    property string httpUserAgent: ""          // Custom user agent for web profiles

    readonly property alias webChannel: channel
    readonly property alias defaultProfile: defaultProfile
    readonly property alias otrProfile: otrProfile
    
    readonly property alias manager: connectorManager
    
    property alias dappUrl: connectorManager.dappUrl
    property alias dappOrigin: connectorManager.dappOrigin
    property alias dappName: connectorManager.dappName
    property alias dappIconUrl: connectorManager.dappIconUrl
    property alias clientId: connectorManager.clientId
    
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
        if (!connectorController) return false
        return connectorController.disconnect(hostname)
    }
    
    function updateDAppUrl(url, name) {
        if (!url) return
        
        const urlStr = url.toString()
        connectorManager.dappUrl = urlStr
        connectorManager.dappOrigin = urlStr
        connectorManager.dappName = name || Utils.extractDomainName(urlStr)
        connectorManager.dappChainId = 1
    }

    function createScript(scriptName, runOnSubframes = true) {
        return {
            name: scriptName,
            sourceUrl: Qt.resolvedUrl("../js/" + scriptName),
            injectionPoint: WebEngineScript.DocumentCreation,
            worldId: WebEngineScript.MainWorld,
            runOnSubframes: runOnSubframes
        }
    }

    readonly property var _scripts: [
        createScript("qwebchannel.js", true),
        createScript("ethereum_wrapper.js", true),
        createScript("eip6963_announcer.js", false), // Only top-level window (EIP-6963 spec)
        createScript("ethereum_injector.js", true)
    ]

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

        onProviderStateChanged: () => eip1193ProviderAdapter.providerStateChanged()
    }

    WebChannel {
        id: channel
        registeredObjects: [eip1193ProviderAdapter]
    }

    Eip1193ProviderAdapter {
        id: eip1193ProviderAdapter
        WebChannel.id: "ethereumProvider"
        
        chainId: Utils.chainIdToHex(connectorManager.dappChainId)
        networkVersion: connectorManager.dappChainId.toString()
        selectedAddress: connectorManager.accounts.length > 0 ? connectorManager.accounts[0] : ""
        accounts: connectorManager.accounts
        connected: connectorManager.connected

        function request(args) {
            return connectorManager.request(args)
        }
    }
}

