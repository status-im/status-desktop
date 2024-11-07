import QtQuick 2.15

import StatusQ.Core.Utils 0.1

QObject {
    id: root
    objectName: "DAppsModel"
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

    // Appending a new DApp to the model
    // Required properties: url, topic, connectorId, accountAddresses
    // Optional properties: name, iconUrl, chains, rawSessions
    function append(dapp) {
        try {
            let {name, url, iconUrl, topic, accountAddresses, connectorId, rawSessions } = dapp
            if (!url || !topic || !connectorId || !accountAddresses) {
                console.warn("DAppsModel - Failed to append dapp, missing required fields", JSON.stringify(dapp))
                return
            }

            name = name || ""
            iconUrl = iconUrl || ""
            accountAddresses = accountAddresses || []
            rawSessions = rawSessions || []

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
        const { dapp, index, sessionIndex } = findDapp(topic)
        if (!dapp) {
            console.warn("DAppsModel - Failed to remove dapp, not found", topic)
            return
        }

        if (dapp.rawSessions.count === 1) {
            root.model.remove(index)
            return
        }

        const rawSession = dapp.rawSessions.get(sessionIndex)
        dapp.rawSessions.remove(sessionIndex)
        if (rawSession.topic == dapp.topic) {
            root.model.setProperty(index, "topic", dapp.rawSessions.get(0).topic)
        }
    }

    function clear() {
        root.model.clear()
    }

    function getByTopic(topic) {
        const dappTemplate = (dapp) => {
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

        const { dapp } = findDapp(topic)
        if (!dapp) {
            return null
        }
        return dappTemplate(dapp)
    }

    function findDapp(topic) {
        for (let i = 0; i < root.model.count; i++) {
            const dapp = root.model.get(i)
            for (let j = 0; j < dapp.rawSessions.count; j++) {
                if (dapp.rawSessions.get(j).topic == topic) {
                    return { dapp, index: i, sessionIndex: j }
                    break
                }
            }
        }

        return { dapp: null, index: -1, sessionIndex: -1 }
    }
}