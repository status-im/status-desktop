pragma Singleton

import QtQuick
import QtQml

import utils
import shared.stores
import shared.stores.send

import StatusQ.Core
import StatusQ.Core.Utils as SQUtils

import "./controls"
import "./views"

QtObject {
    id: root

    enum RecipientAddressObjectType {
        Address, // Just a string with the address information / default
        Account, // Wallet account object
        SavedAddress, // Saved addresses object
        RecentsAddress // Recent addresses object got from transactions history
    }

    function recipientAddressObjectTypeToString(type) {
        switch (type) {
            case RecipientAddressObjectType.Address:
                return "Address"
            case RecipientAddressObjectType.Account:
                return "Account"
            case RecipientAddressObjectType.SavedAddress:
                return "SavedAddress"
            case RecipientAddressObjectType.RecentsAddress:
                return "RecentsAddress"
            default:
                return "Unknown"
        }
    }

    function createSendModalRequirements() {
        return {
            preSelectedAccount: null,
            preSelectedRecipientType: Helpers.RecipientAddressObjectType.Address,
            preSelectedRecipient: null,
            preSelectedHoldingType: Constants.TokenType.Unknown,
            preSelectedHoldingID: "",
            preDefinedAmountToSend: "",
            preSelectedChainId: 0,
            preSelectedSendType: Constants.SendType.Transfer
        }
    }

    // \c token is an collectible object in case of \c isCollectible == true otherwise a token code (e.g. "ETH")
    function lookupAddressesForSendModal(accountsModel,
                                         savedAddressesModel,
                                         senderAddress,
                                         recipientAddress,
                                         token,
                                         isCollectible,
                                         amount,
                                         chainId) {
        let req = createSendModalRequirements()

        req.preSelectedSendType = Constants.SendType.Transfer

        // Sender properties:
        let senderAccount = null
        let resolvedAcc = SQUtils.ModelUtils.getByKey(accountsModel, "address", senderAddress)
        if (resolvedAcc) {
            req.preSelectedAccount = resolvedAcc
            req.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Account
        }

        // Recipients properties:
        const resAcc = SQUtils.ModelUtils.getByKey(accountsModel, "address", recipientAddress)
        let resSaved = SQUtils.ModelUtils.getByKey(savedAddressesModel, "address", recipientAddress)
        if (resAcc) {
            req.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Account
            req.preSelectedRecipient = resAcc
        } else if (resSaved) {
            req.preSelectedRecipientType = Helpers.RecipientAddressObjectType.SavedAddress
            req.preSelectedRecipient = resSaved
        } else {
            req.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Address
            req.preSelectedRecipient = recipientAddress
        }

        req.preSelectedHoldingType = isCollectible ? Constants.TokenType.ERC721 : Constants.TokenType.ERC20
        req.preSelectedHoldingID = token
        req.preSelectedChainId = chainId

        req.preDefinedAmountToSend = LocaleUtils.numberToLocaleString(amount)

        return req
    }

    function assetsSectionTitle(sectionNeeded, hasCommunityTokens, isInsideCollection, isERC20List) {
        let title = ""
        if (!isInsideCollection) {
            if (sectionNeeded) {
                title = qsTr("Community minted")
            } else {
                if (!isERC20List) {
                    // Show "Other" only if there are "Community minted" tokens on the list
                    if (hasCommunityTokens) {
                        title = qsTr("Other")
                    }
                }
            }
        }
        return title
    }

    function modelHasCommunityTokens(model, isERC20List) {
        if (model.count > 0) {
            let item
            if (isERC20List) {
                item = model.get(model.count - 1)
            } else {
                item = model.get(0)
            }
            return item.isCommunityAsset
        }

        return false
    }
}
