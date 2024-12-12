import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.popups.simpleSend 1.0

import shared.popups.send 1.0
import shared.stores.send 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent
    required property int loginType
    required property TransactionStore transactionStore
    required property WalletStores.CollectiblesStore walletCollectiblesStore

    // for ens flows
    required property string myPublicKey
    required property string ensRegisteredAddress
    // TODO: This should probably be a property and not a function. Needs changes on  backend side
    property var getStatusTokenKey: function() {}

    // for sticker flows
    required property string stickersMarketAddress
    required property string stickersNetworkId

    // Feature flag for single network send until its feature complete
    required property bool simpleSendEnabled

    function openSend(params = {}) {
        // TODO remove once simple send is feature complete
        let sendModalCmp = root.simpleSendEnabled ? simpleSendModalComponent: sendModalComponent
        let sendModalInst = sendModalCmp.createObject(popupParent, params)
        sendModalInst.open()
    }

    function connectUsername(ensName) {
        let params = {
            preSelectedSendType: Constants.SendType.ENSSetPubKey,
            preSelectedHoldingID: Constants.ethToken ,
            preSelectedHoldingType: Constants.TokenType.Native,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0),
            preSelectedRecipient: root.ensRegisteredAddress,
            interactive: false,
            publicKey: root.myPublicKey,
            ensName: ensName
        }
        openSend(params)
    }

    function registerUsername(ensName) {
        let params = {
            preSelectedSendType: Constants.SendType.ENSRegister,
            preSelectedHoldingID: root.getStatusTokenKey(),
            preSelectedHoldingType: Constants.TokenType.ERC20,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(10),
            preSelectedRecipient: root.ensRegisteredAddress,
            interactive: false,
            publicKey: root.myPublicKey,
            ensName: ensName
        }
        openSend(params)
    }

    function releaseUsername(ensName, senderAddress, chainId) {
        let params = {
            preSelectedSendType: Constants.SendType.ENSRelease,
            preSelectedAccountAddress: senderAddress,
            preSelectedHoldingID: Constants.ethToken ,
            preSelectedHoldingType: Constants.TokenType.Native,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0),
            preSelectedChainId: chainId,
            preSelectedRecipient: root.ensRegisteredAddress,
            interactive: false,
            publicKey: root.myPublicKey,
            ensName: ensName
        }
        openSend(params)
    }

    function buyStickerPack(packId, price) {
        let params = {
            preSelectedSendType: Constants.SendType.StickersBuy,
            preSelectedHoldingID: root.getStatusTokenKey(),
            preSelectedHoldingType: Constants.TokenType.ERC20,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(price),
            preSelectedChainId: root.stickersNetworkId,
            preSelectedRecipient: root.stickersMarketAddress,
            interactive: false,
            stickersPackId: packId
        }
        openSend(params)
    }

    function transferOwnership(tokenId, senderAddress) {
        let params = {
            preSelectedSendType: Constants.SendType.ERC721Transfer,
            preSelectedAccountAddress: senderAddress,
            preSelectedHoldingID: tokenId,
            preSelectedHoldingType:  Constants.TokenType.ERC721,
        }
        openSend(params)
    }

    function sendToRecipient(recipientAddress) {
        let params = {
            preSelectedRecipient: recipientAddress
        }
        openSend(params)
    }

    function bridgeToken(tokenId, tokenType) {
        let params = {
            preSelectedSendType: Constants.SendType.Bridge,
            preSelectedHoldingID: tokenId ,
            preSelectedHoldingType: tokenType,
            onlyAssets: true
        }
        openSend(params)
    }

    function sendToken(senderAddress, tokenId, tokenType) {
        let sendType = Constants.SendType.Transfer
        if (tokenType === Constants.TokenType.ERC721)  {
            sendType = Constants.SendType.ERC721Transfer
        } else if(tokenType === Constants.TokenType.ERC1155) {
            sendType = Constants.SendType.ERC1155Transfer
        }
        let params = {
            preSelectedSendType: sendType,
            preSelectedAccountAddress: senderAddress,
            preSelectedHoldingID: tokenId ,
            preSelectedHoldingType: tokenType,
        }
        openSend(params)
    }

    function openTokenPaymentRequest(recipientAddress, symbol, rawAmount, chainId) {
        const params = {
            preSelectedHoldingID: symbol,
            preSelectedHoldingType: Constants.TokenType.ERC20,
            preDefinedRawAmountToSend: rawAmount,
            preSelectedChainId: chainId,
            preSelectedRecipient: recipientAddress
        }
        openSend(params)
    }

    readonly property Component sendModalComponent: Component {
        SendModal {
            loginType: root.loginType

            store: root.transactionStore
            collectiblesStore: root.walletCollectiblesStore

            showCustomRoutingMode: !production

            onClosed: destroy()
        }
    }

    readonly property Component simpleSendModalComponent: Component {
        SimpleSendModal {
            onClosed: destroy()
        }
    }
}
