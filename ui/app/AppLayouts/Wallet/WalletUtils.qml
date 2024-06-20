pragma Singleton

import QtQuick 2.14

import utils 1.0
import StatusQ.Core.Theme 0.1

import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet.stores 1.0 as WalletStores

QtObject {

    property QtObject _d: QtObject {
        id: d

        property var chainColors: ({})

        function initChainColors(model) {
            for (let i = 0; i < model.count; i++) {
                const item = SQUtils.ModelUtils.get(model, i)
                chainColors[item.shortName] = item.chainColor
            }
        }

        function colorForChainShortName(chainShortName) {
            return d.chainColors[chainShortName]
        }

        readonly property Connections walletRootStoreConnections: Connections {
            target: WalletStores.RootStore

            function onFlatNetworksChanged() {
                d.initChainColors(WalletStores.RootStore.flatNetworks)
            }
        }

    }

    function colorizedChainPrefix(prefix) {
        if (!prefix)
            return ""

        const prefixes = prefix.split(":").filter(Boolean)
        let prefixStr = ""
        const lastPrefixEndsWithColumn = prefix.endsWith(":")
        const defaultColor = Theme.palette.baseColor1

        for (let i in prefixes) {
            const pref = prefixes[i]
            let col = d.colorForChainShortName(pref)
            if (!col)
                col = defaultColor

            prefixStr += Utils.richColorText(pref, col)
            // Avoid adding ":" if it was not there for the last prefix,
            // because when user manually edits the address, it breaks editing
            if (!(i == (prefixes.length - 1) && !lastPrefixEndsWithColumn)) {
                prefixStr += Utils.richColorText(":", Theme.palette.baseColor1)
            }
        }

        return prefixStr
    }

    function calculateConfirmationTimestamp(chainLayer, timestamp) {
        if (chainLayer === 1) {
            return timestamp + 12 * 4 // A block on layer1 is every 12s
        }
        return timestamp
    }

    function calculateFinalisationTimestamp(chainLayer, timestamp) {
        if (chainLayer === 1) {
            return timestamp + 12 * 64 // A block on layer1 is every 12s
        }
        return timestamp + Constants.time.secondsIn7Days
    }

    function addressToDisplay(address, chainShortNames, shortForm, hovered) {
        let finalAddress = address
        if (shortForm) {
            finalAddress = StatusQUtils.Utils.elideText(address,6,4)
        }
        return hovered? WalletUtils.colorizedChainPrefix(chainShortNames) + Utils.richColorText(finalAddress, Theme.palette.directColor1) : chainShortNames + finalAddress
    }

    /**
      Calculate max safe amount to be used when making a transaction

      This logic is here to make sure there is enough eth to pay for the gas.
      Context, when making a transaction, whatever the type: swap/bridge/send, you need eth to pay for the gas.

      rationale: https://github.com/status-im/status-desktop/pull/14959#discussion_r1627110880
      */
    function calculateMaxSafeSendAmount(value, symbol) {
        if (symbol !== Constants.ethToken || value === 0) {
            return value
        }

        return value - Math.max(0.0001, Math.min(0.01, value * 0.1))
    }

    function getAssetForSendTx(tx) {
        if (tx.isNFT) {
            return {
                uid: tx.tokenID,
                chainId: tx.chainId,
                name: tx.nftName,
                imageUrl: tx.nftImageUrl,
                collectionUid: "",
                collectionName: ""
            }
        } else {
            return tx.symbol
        }
    }

    function isTxRepeatable(tx) {
        if (!tx || tx.txType !== Constants.TransactionType.Send)
            return false

        let res = root.lookupAddressObject(tx.sender)
        if (!res || res.type !== RootStore.LookupType.Account || res.object.walletType == Constants.watchWalletType)
            return false

        if (tx.isNFT) {
            // TODO #12275: check if account owns enough NFT
        } else {
            // TODO #12275: Check if account owns enough tokens
        }

        return true
    }

    function getExplorerNameForNetwork(networkShortName)  {
        if (networkShortName === Constants.networkShortChainNames.arbitrum) {
            return qsTr("Arbiscan Explorer")
        }
        if (networkShortName === Constants.networkShortChainNames.optimism) {
            return qsTr("Optimism Explorer")
        }
        return qsTr("Etherscan Explorer")
    }

    function getTwitterLink(twitterHandle) {
        const prefix = Constants.socialLinkPrefixesByType[Constants.socialLinkType.twitter]
        return prefix + twitterHandle
    }
}
