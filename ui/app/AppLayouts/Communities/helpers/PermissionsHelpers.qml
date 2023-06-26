pragma Singleton

import QtQml 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.controls 1.0

QtObject {
    function getTokenByKey(model, key) {
        if (!model)
            return null

        const count = model.rowCount()

        for (let i = 0; i < count; i++) {
            const item = ModelUtils.get(model, i)

            if (item.key === key)
                return item

            if (item.subItems) {
                const subitem = getTokenByKey(item.subItems, key)

                if (subitem !== null)
                    return subitem
            }
        }

        return null
    }

    function getTokenNameByKey(model, key) {
        const item = getTokenByKey(model, key)
        if (item)
            return item.name
        return ""
    }

    function getTokenShortNameByKey(model, key) {
        const item = getTokenByKey(model, key)
        if (item)
            return item.shortName ?? ""
        return ""
    }

    function getTokenIconByKey(model, key) {
        const item = getTokenByKey(model, key)
        if (item)
            return item.iconSource ?? ""
        return ""
    }

    function getTokenAmountByKey(model, key) {
        const item = getTokenByKey(model, key)
        if (item) {
            if (item.infiniteSupply === true)
                return "∞"

            return item.supply ?? ""
        }
        return ""
    }

    function setHoldingsTextFormat(type, name, amount) {
        switch (type) {
            case HoldingTypes.Type.Asset:
                return `${LocaleUtils.numberToLocaleString(amount)} ${name}`
            case HoldingTypes.Type.Collectible:
                if (amount === 1)
                    return name
                return `${LocaleUtils.numberToLocaleString(amount)} ${name}`
            case HoldingTypes.Type.Ens:
                if (name === "*.eth")
                    return qsTr("Any ENS username")
                if (name.startsWith("*."))
                    return qsTr("ENS username on '%1' domain").arg(name.substring(2))

                return qsTr("ENS username '%1'").arg(name)
            default:
                return ""
        }
    }
}
