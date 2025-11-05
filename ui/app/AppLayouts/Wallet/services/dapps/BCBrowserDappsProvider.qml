import QtQuick

import AppLayouts.Wallet.services.dapps
import StatusQ.Core.Utils

import shared.stores
import utils

DAppsModel {
    id: root
    
    required property var connectorController
    property var clientId: null  // null = all dApps, "" or specific value = exact match filter
    
    readonly property int connectorId: Constants.StatusConnect
    readonly property bool enabled: !!connectorController
    
    signal connected(string dappUrl)
    signal disconnected(string dappUrl)
    
    Connections {
        target: root.connectorController
        enabled: root.enabled
        
        function onConnected(payload) {
            d.handleSignal(payload, "connected")
        }
        
        function onDisconnected(payload) {
            d.handleSignal(payload, "disconnected")
        }
        
        function onAccountChanged(payload) {
            d.handleSignal(payload, "accountChanged")
        }
    }
    
    QtObject {
        id: d
        
        function handleSignal(payload, signalName) {
            try {
                const data = JSON.parse(payload)
                if (root.clientId !== null && data.clientId !== root.clientId) {
                    return
                }
                
                d.refreshModel()
            } catch (error) {
                console.error("[BCBrowserDappsProvider] Error processing", signalName, "signal:", error)
            }
        }
        
        function getConnectorBadge(connectorId) {
            // Constants.dappImageByType mapping:
            // 0: Status logo (StatusConnect)
            // 1: WalletConnect icon
            // 2: Status logo (Browser)
            const dappImageByType = [
                "status-logo",
                "network/Network=WalletConnect",
                "status-logo"
            ]
            return dappImageByType[connectorId] || ""
        }
        
        function refreshModel() {
            if (!root.connectorController) {
                return
            }
            
            root.clear()
            
            let dAppsJson
            if (root.clientId === null) {
                dAppsJson = root.connectorController.getDApps()
            } else {
                dAppsJson = root.connectorController.getDAppsByClientId(root.clientId)
            }
            
            const dApps = JSON.parse(dAppsJson)

            for (let i = 0; i < dApps.length; i++) {
                const dapp = dApps[i]
                const badge = d.getConnectorBadge(root.connectorId)

                const dappEntry = {
                    url: dapp.url,
                    name: dapp.name,
                    iconUrl: dapp.iconUrl || "",
                    topic: dapp.url,  // Use URL as topic for Browser Connector
                    connectorId: root.connectorId,
                    connectorBadge: badge,
                    accountAddresses: dapp.sharedAccount ? [{address: dapp.sharedAccount}] : [],
                    rawSessions: []
                }
                root.append(dappEntry)
            }
        }
    }
    
    Component.onCompleted: {
        d.refreshModel()
    }
}

