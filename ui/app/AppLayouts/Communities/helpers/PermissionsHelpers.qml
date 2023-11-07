pragma Singleton

import QtQml 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Internal 0.1 as Internal

import AppLayouts.Communities.controls 1.0

import utils 1.0

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

    function getTokenRemainingSupplyByKey(model, key) {
        const item = getTokenByKey(model, key)

        if (!item || item.remainingSupply === undefined
                || item.multiplierIndex === undefined)
            return ""

        if (item.infiniteSupply)
            return "∞"

        return LocaleUtils.numberToLocaleString(
                    AmountsArithmetic.toNumber(item.remainingSupply,
                                               item.multiplierIndex))
    }

    function getUniquePermissionTokenKeys(model) {
        return Internal.PermissionUtils.getUniquePermissionTokenKeys(model)
    }

    function getUniquePermissionChannels(model, permissionsTypesArray = []) {
        return Internal.PermissionUtils.getUniquePermissionChannels(model, permissionsTypesArray)
    }

    function setHoldingsTextFormat(type, name, amount) {
        if (typeof amount === "string")
            amount = AmountsArithmetic.toNumber(AmountsArithmetic.fromString(amount))

        switch (type) {
            case Constants.TokenType.ERC20:
                return `${LocaleUtils.numberToLocaleString(amount)} ${name}`
            case Constants.TokenType.ERC721:
                if (amount === 1)
                    return name
                return `${LocaleUtils.numberToLocaleString(amount)} ${name}`
            case Constants.TokenType.ENS:
                if (name === "*.eth")
                    return qsTr("Any ENS username")
                if (name.startsWith("*."))
                    return qsTr("ENS username on '%1' domain").arg(name.substring(2))

                return qsTr("ENS username '%1'").arg(name)
            default:
                return ""
        }
    }

    // OWNER AND TMASTER TOKENS related helpers:
    readonly property string ownerTokenNameTag: "Owner-"
    readonly property string tMasterTokenNameTag: "TMaster-"
    readonly property string ownerTokenSymbolTag: "OWN"
    readonly property string tMasterTokenSymbolTag: "TM"

    // It generates a symbol from a given community name.
    // It will be used to autogenerate the Owner and Token Master token symbols.
    function communityNameToSymbol(isOwner, communityName) {
        const shortName = communityName.substring(0, 3)
        if(isOwner)
            return ownerTokenSymbolTag + shortName.toUpperCase()
        else
            return tMasterTokenSymbolTag + shortName.toUpperCase()
    }
}
