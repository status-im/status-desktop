import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import StatusQ.Core.Utils 0.1

import shared.stores 1.0
import utils 1.0

QObject {
    id: root

    readonly property alias dappsModel: d.dappsModel
    readonly property int connectorId: Constants.StatusConnect
    property bool enabled: true

    function addSession(url, name, iconUrl, accountAddress) {
        if (!enabled) {
            return
        }

        if (!url || !name || !iconUrl || !accountAddress) {
            console.error("addSession: missing required parameters")
            return
        }

        const topic = url
        const activeSession = getActiveSession(topic)
        if (!activeSession) {
            d.addSession({
                url,
                name,
                iconUrl,
                topic,
                connectorId: root.connectorId,
                accountAddresses: [{address: accountAddress}]
            })
            return
        }

        if (!ModelUtils.contains(activeSession.accountAddresses, "address", accountAddress, Qt.CaseInsensitive)) {
            activeSession.accountAddresses.append({address: accountAddress})
        }
    }

    function revokeSession(topic) {
        if (!enabled) {
            return
        }

        d.revokeSession(topic)
    }

    function getActiveSession(topic) {
        if (!enabled) {
            return
        }

        return d.getActiveSession(topic)
    }

    QObject {
        id: d

        property ListModel dappsModel: ListModel {
            id: dapps
        }

        function addSession(dappItem) {
            dapps.append(dappItem)
        }

        function revokeSession(topic) {
            for (let i = 0; i < dapps.count; i++) {
                let existingDapp = dapps.get(i)
                if (existingDapp.topic === topic) {
                    dapps.remove(i)
                    break
                }
            }
        }

        function revokeAllSessions() {
            for (let i = 0; i < dapps.count; i++) {
                dapps.remove(i)
            }
        }

        function getActiveSession(topic) {
            for (let i = 0; i < dapps.count; i++) {
                const existingDapp = dapps.get(i)

                if (existingDapp.topic === topic) {
                    return {
                        name: existingDapp.name,
                        url: existingDapp.url,
                        icon: existingDapp.iconUrl,
                        topic: existingDapp.topic,
                        connectorId: existingDapp.connectorId,
                        accountAddresses: existingDapp.accountAddresses
                    };
                }
            }
            return null
        }
    }
}
