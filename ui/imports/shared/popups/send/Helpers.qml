pragma Singleton

import QtQuick 2.15
import QtQml 2.15

import utils 1.0
import shared.stores 1.0
import shared.stores.send 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores

import StatusQ.Core 0.1

import "./panels"
import "./controls"
import "./views"

QtObject {
    id: root

    function createSendModalRequirements() {
        return {
            preSelectedAccount: null,
            preSelectedRecipientType: TabAddressSelectorView.Type.Address,
            preSelectedRecipient: null,
            preSelectedHoldingType: Constants.TokenType.Unknown,
            preSelectedHolding: null,
            preSelectedHoldingID: "",
            preDefinedAmountToSend: "",
            preSelectedSendType: Constants.SendType.Transfer
        }
    }

    // \c token is an collectible object in case of \c isCollectible == true otherwise a token code (e.g. "ETH")
    function lookupAddressesForSendModal(senderAddress, recipientAddress, token, isCollectible, amount) {
        let req = createSendModalRequirements()

        req.preSelectedSendType = Constants.SendType.Transfer
        let senderAccount = null
        let resolvedAcc = WalletStores.RootStore.lookupAddressObject(senderAddress)
        if (resolvedAcc && resolvedAcc.type == WalletStores.RootStore.LookupType.Account) {
            req.preSelectedAccount = resolvedAcc.object
        }

        let res = WalletStores.RootStore.lookupAddressObject(recipientAddress)
        if (res) {
            if (res.type == WalletStores.RootStore.LookupType.Account) {
                req.preSelectedRecipientType = TabAddressSelectorView.Type.Account
                req.preSelectedRecipient = res.object
            } else if (res.type == WalletStores.RootStore.LookupType.SavedAddress) {
                req.preSelectedRecipientType = TabAddressSelectorView.Type.SavedAddress
                req.preSelectedRecipient = res.object
            }
        } else {
            req.preSelectedRecipientType = TabAddressSelectorView.Type.Address
            req.preSelectedRecipient = recipientAddress
        }

        if (isCollectible) {
            req.preSelectedHoldingType = Constants.TokenType.ERC721
            req.preSelectedHolding = token
        } else {
            req.preSelectedHoldingType = Constants.TokenType.ERC20
            req.preSelectedHoldingID = token
        }

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
