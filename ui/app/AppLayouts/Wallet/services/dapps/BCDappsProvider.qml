import QtQuick

import AppLayouts.Wallet.services.dapps
import utils

DAppsModel {
    id: root
    
    required property WalletConnectSDKBase bcSDK

    readonly property int connectorId: Constants.StatusConnect
    readonly property bool enabled: bcSDK.enabled

    signal connected(string pairingId, string topic, string dAppUrl)
    signal disconnected(string topic, string dAppUrl)

    Connections {
        target: root.bcSDK
        enabled: root.enabled

        function onSessionDelete(topic, err) {
            const dapp = root.getByTopic(topic)
            if (!dapp) {
                console.warn("DApp not found for topic - cannot delete session", topic)
                return
            }

            root.remove(topic)
            root.disconnected(topic, dapp.url)
        }

        function onApproveSessionResult(proposalId, session, error) {
            if (error) {
                console.warn("Failed to approve session", error)
                return
            }

            const dapp = d.sessionToDApp(session)
            root.append(dapp)
            root.connected(proposalId, dapp.topic, dapp.url)
        }
    }

    QtObject {
        id: d
        function sessionToDApp(session) {
            const dapp = session.peer.metadata
            if (!!dapp.icons && dapp.icons.length > 0) {
                dapp.iconUrl = dapp.icons[0]
            } else {
                dapp.iconUrl = ""
            }
            const accounts = DAppsHelpers.getAccountsInSession(session)
            dapp.accountAddresses = accounts.map(account => ({address: account}))
            dapp.topic = session.topic
            dapp.rawSessions = [session]
            dapp.connectorId = root.connectorId
            return dapp
        }
        function getPersistedDapps() {
            if (!root.enabled) {
                return []
            }
            let dapps = []
            root.bcSDK.getActiveSessions((allSessions) => {
                if (!allSessions) {
                    return
                }

                for (const sessionID in allSessions) {
                    const session = allSessions[sessionID]
                    const dapp = sessionToDApp(session)
                    dapps.push(dapp)
                }
            })
            return dapps
        }

        function resetModel() {
            root.clear()
            const dapps = d.getPersistedDapps()
            for (let i = 0; i < dapps.length; i++) {
                root.append(dapps[i])
            }
        }
    }

    Component.onCompleted: {
        d.resetModel()
    }
}
