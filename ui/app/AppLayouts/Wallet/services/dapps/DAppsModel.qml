import QtQuick 2.15

import StatusQ.Core.Utils 0.1

QObject {
    id: root
    // RoleNames
    // name: string
    // url: string
    // iconUrl: string
    // topic: string
    // connectorId: int
    // accountAddressses: [{address: string}]
    // chains: string
    // rawSessions: [{session: object}]
    readonly property ListModel model: ListModel {}

    function append(dapp) {
        try {
            const {name, url, iconUrl, topic, accountAddresses, connectorId, rawSessions } = dapp
            if (!name || !url || !iconUrl || !topic || !connectorId || !accountAddresses || !rawSessions) {
                console.warn("DAppsModel - Failed to append dapp, missing required fields", JSON.stringify(dapp))
                return
            }

            root.model.append({
                name,
                url,
                iconUrl,
                topic,
                connectorId,
                accountAddresses,
                rawSessions
            })
        } catch (e) {
            console.warn("DAppsModel - Failed to append dapp", e)
        }
    }

    function remove(topic) {
        for (let i = 0; i < root.model.count; i++) {
            const dapp = root.model.get(i)
            if (dapp.topic == topic) {
                root.model.remove(i)
                break
            }
        }
    }

    function clear() {
        root.model.clear()
    }

    function getByTopic(topic) {
        for (let i = 0; i < root.model.count; i++) {
            const dapp = root.model.get(i)
            if (dapp.topic == topic) {
                return {
                    name: dapp.name,
                    url: dapp.url,
                    iconUrl: dapp.iconUrl,
                    topic: dapp.topic,
                    connectorId: dapp.connectorId,
                    accountAddresses: dapp.accountAddresses,
                    rawSessions: dapp.rawSessions
                }
            }
        }
        return null
    }
}