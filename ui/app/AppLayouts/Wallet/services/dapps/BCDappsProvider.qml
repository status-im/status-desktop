import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import StatusQ.Core.Utils 0.1

import shared.stores 1.0
import utils 1.0

DAppsModel {
    id: root
    
    required property BrowserConnectStore store

    readonly property int connectorId: Constants.StatusConnect
    property bool enabled: true

    Connections {
        target: root.store
        enabled: root.enabled

        function onConnected(dappJson) {
            const dapp = JSON.parse(dappJson)
            const { url, name, icon, sharedAccount } = dapp

            if (!url) {
                console.warn(invalidDAppUrlError)
                return
            }
            root.append({
                name,
                url,
                iconUrl: icon,
                topic: url,
                connectorId: root.connectorId,
                accountAddresses: [{address: sharedAccount}],
                rawSessions: [dapp]
            })
        }

        function onDisconnected(dappJson) {
            const dapp = JSON.parse(dappJson)
            const { url } = dapp

            if (!url) {
                console.warn(invalidDAppUrlError)
                return
            }
            root.remove(dapp.url)
        }
    }

    Component.onCompleted: {
        if (root.enabled) {
            const dappsStr = root.store.getDApps()
            if (dappsStr) {
                const dapps = JSON.parse(dappsStr)
                dapps.forEach(dapp => {
                    const { url, name, iconUrl, sharedAccount } = dapp
                    root.append({
                        name,
                        url,
                        iconUrl,
                        topic: url,
                        connectorId: root.connectorId,
                        accountAddresses: [{address: sharedAccount}],
                        rawSessions: [dapp]
                    })
                })
            }
        }
    }
}
