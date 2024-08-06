pragma Singleton

import QtQuick 2.14

import utils 1.0
import StatusQ.Core.Theme 0.1

import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet.stores 1.0 as WalletStores

QtObject {

    function colorizedChainPrefixNew(chainColors, prefix) {
        if (!prefix)
            return ""

        const prefixes = prefix.split(":").filter(Boolean)
        let prefixStr = ""
        const lastPrefixEndsWithColumn = prefix.endsWith(":")
        const defaultColor = Theme.palette.baseColor1

        for (let i in prefixes) {
            const pref = prefixes[i]
            let col = chainColors[pref]
            if (!col)
                col = defaultColor

            prefixStr += Utils.richColorText(pref, col)
            // Avoid adding ":" if it was not there for the last prefix,
            // because when user manually edits the address, it breaks editing
            if (!(i === (prefixes.length - 1) && !lastPrefixEndsWithColumn)) {
                prefixStr += Utils.richColorText(":", Theme.palette.baseColor1)
            }
        }

        return prefixStr
    }

    // TODO: Remove dependency to RootStore by requesting model or chainColors as a parameter. Indeed, this
    // method should be just replaced by `colorizedChainPrefixNew`
    // Issue #15494
    function colorizedChainPrefix(prefix) {
        if (!prefix)
            return ""

        const prefixes = prefix.split(":").filter(Boolean)
        let prefixStr = ""
        const lastPrefixEndsWithColumn = prefix.endsWith(":")
        const defaultColor = Theme.palette.baseColor1

        for (let i in prefixes) {
            const pref = prefixes[i]
            let col = WalletStores.RootStore.colorForChainShortName(pref)
            if (!col)
                col = defaultColor

            prefixStr += Utils.richColorText(pref, col)
            // Avoid adding ":" if it was not there for the last prefix,
            // because when user manually edits the address, it breaks editing
            if (!(i === (prefixes.length - 1) && !lastPrefixEndsWithColumn)) {
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

    function getLabelForEstimatedTxTime(estimatedFlag) {
        switch(estimatedFlag) {
        case Constants.TransactionEstimatedTime.Unknown:
            return qsTr("~ Unknown")
        case Constants.TransactionEstimatedTime.LessThanOneMin :
            return qsTr("< 1 minute")
        case Constants.TransactionEstimatedTime.LessThanThreeMins :
            return qsTr("< 3 minutes")
        case Constants.TransactionEstimatedTime.LessThanFiveMins:
            return qsTr("< 5 minutes")
        default:
            return qsTr("> 5 minutes")
        }
    }

    // Where: chainIds [string] - separated by `:`, e.g "42161:10:1"
    function getNetworkShortNames(chainIds: string, flatNetworksModel) {
        let networkString = ""
        const chainIdsArray = chainIds.split(":")
        for (let i = 0; i < chainIdsArray.length; i++) {
            const nwShortName = StatusQUtils.ModelUtils.getByKey(flatNetworksModel, "chainId", Number(chainIdsArray[i]), "shortName")
            if (!!nwShortName)
                networkString = networkString + nwShortName + ':'
        }
        return networkString
    }



    function getRouterErrorBasedOnCode(code) {
        if (code === "") {
            return ""
        }

        switch(code) {
        case Constants.routerErrorCodes.errGeneric:
            return qsTr("unknown error occurred, try again later")
        case Constants.routerErrorCodes.processor.errFailedToParseBaseFee:
        case Constants.routerErrorCodes.processor.errFailedToParsePercentageFee:
        case Constants.routerErrorCodes.processor.errContractNotFound:
        case Constants.routerErrorCodes.processor.errNetworkNotFound:
        case Constants.routerErrorCodes.processor.errTokenNotFound:
        case Constants.routerErrorCodes.processor.errNoEstimationFound:
        case Constants.routerErrorCodes.processor.errNotAvailableForContractType:
        case Constants.routerErrorCodes.processor.errNoBonderFeeFound:
        case Constants.routerErrorCodes.processor.errContractTypeNotSupported:
        case Constants.routerErrorCodes.processor.errFromChainNotSupported:
        case Constants.routerErrorCodes.processor.errToChainNotSupported:
        case Constants.routerErrorCodes.processor.errTxForChainNotSupported:
        case Constants.routerErrorCodes.processor.errENSResolverNotFound:
        case Constants.routerErrorCodes.processor.errENSRegistrarNotFound:
        case Constants.routerErrorCodes.processor.errToAndFromTokensMustBeSet:
        case Constants.routerErrorCodes.processor.errCannotResolveTokens:
        case Constants.routerErrorCodes.processor.errPriceRouteNotFound:
        case Constants.routerErrorCodes.processor.errConvertingAmountToBigInt:
        case Constants.routerErrorCodes.processor.errNoChainSet:
        case Constants.routerErrorCodes.processor.errNoTokenSet:
        case Constants.routerErrorCodes.processor.errToTokenShouldNotBeSet:
        case Constants.routerErrorCodes.processor.errFromAndToChainsMustBeDifferent:
        case Constants.routerErrorCodes.processor.errFromAndToChainsMustBeSame:
        case Constants.routerErrorCodes.processor.errFromAndToTokensMustBeDifferent:
        case Constants.routerErrorCodes.processor.errContextCancelled:
        case Constants.routerErrorCodes.processor.errContextDeadlineExceeded:
        case Constants.routerErrorCodes.processor.errPriceTimeout:
        case Constants.routerErrorCodes.processor.errNotEnoughLiquidity:
        case Constants.routerErrorCodes.processor.errPriceImpactTooHigh:
            return qsTr("processor internal error")
        case Constants.routerErrorCodes.processor.errTransferCustomError:
        case Constants.routerErrorCodes.processor.errERC721TransferCustomError:
        case Constants.routerErrorCodes.processor.errERC1155TransferCustomError:
        case Constants.routerErrorCodes.processor.errBridgeHopCustomError:
        case Constants.routerErrorCodes.processor.errBridgeCellerCustomError:
        case Constants.routerErrorCodes.processor.errSwapParaswapCustomError:
        case Constants.routerErrorCodes.processor.errENSRegisterCustomError:
        case Constants.routerErrorCodes.processor.errENSReleaseCustomError:
        case Constants.routerErrorCodes.processor.errENSPublicKeyCustomError:
        case Constants.routerErrorCodes.processor.errStickersBuyCustomError:
            return qsTr("processor network error")
        case Constants.routerErrorCodes.router.errENSRegisterRequiresUsernameAndPubKey:
        case Constants.routerErrorCodes.router.errENSRegisterTestnetSTTOnly:
        case Constants.routerErrorCodes.router.errENSRegisterMainnetSNTOnly:
        case Constants.routerErrorCodes.router.errENSReleaseRequiresUsername:
        case Constants.routerErrorCodes.router.errENSSetPubKeyRequiresUsernameAndPubKey:
        case Constants.routerErrorCodes.router.errStickersBuyRequiresPackID:
        case Constants.routerErrorCodes.router.errSwapRequiresToTokenID:
        case Constants.routerErrorCodes.router.errSwapTokenIDMustBeDifferent:
        case Constants.routerErrorCodes.router.errSwapAmountInAmountOutMustBeExclusive:
        case Constants.routerErrorCodes.router.errSwapAmountInMustBePositive:
        case Constants.routerErrorCodes.router.errSwapAmountOutMustBePositive:
        case Constants.routerErrorCodes.router.errLockedAmountNotSupportedForNetwork:
        case Constants.routerErrorCodes.router.errLockedAmountNotNegative:
        case Constants.routerErrorCodes.router.errLockedAmountExceedsTotalSendAmount:
        case Constants.routerErrorCodes.router.errLockedAmountLessThanSendAmountAllNetworks:
        case Constants.routerErrorCodes.router.errNativeTokenNotFound:
        case Constants.routerErrorCodes.router.errDisabledChainFoundAmongLockedNetworks:
        case Constants.routerErrorCodes.router.errENSSetPubKeyInvalidUsername:
        case Constants.routerErrorCodes.router.errLockedAmountExcludesAllSupported:
        case Constants.routerErrorCodes.router.errTokenNotFound:
        case Constants.routerErrorCodes.router.errNoBestRouteFound:
        case Constants.routerErrorCodes.router.errCannotCheckReceiverBalance:
        case Constants.routerErrorCodes.router.errCannotCheckLockedAmounts:
            return qsTr("router network error")
        case Constants.routerErrorCodes.router.errNotEnoughTokenBalance:
            return qsTr("not enough token balance")
        case Constants.routerErrorCodes.router.errNotEnoughNativeBalance:
            return qsTr("not enough ETH")
        case Constants.routerErrorCodes.router.errLowAmountInForHopBridge:
            return qsTr("amount in too low")
        default:
            return qsTr("unknown processor error")
        }
    }

    function getRouterErrorDetailsOnCode(code, details) {
        if (code === "") {
            return ""
        }

        switch(code) {
        case Constants.routerErrorCodes.errGeneric:
            return details
        case Constants.routerErrorCodes.processor.errFailedToParseBaseFee:
            return qsTr("failed to parse base fee")
        case Constants.routerErrorCodes.processor.errFailedToParsePercentageFee:
            return sTr("failed to parse percentage fee")
        case Constants.routerErrorCodes.processor.errContractNotFound:
            return sTr("contract not found")
        case Constants.routerErrorCodes.processor.errNetworkNotFound:
            return sTr("network not found")
        case Constants.routerErrorCodes.processor.errTokenNotFound:
            return sTr("token not found")
        case Constants.routerErrorCodes.processor.errNoEstimationFound:
            return sTr("no estimation found")
        case Constants.routerErrorCodes.processor.errNotAvailableForContractType:
            return sTr("not available for contract type")
        case Constants.routerErrorCodes.processor.errNoBonderFeeFound:
            return sTr("no bonder fee found")
        case Constants.routerErrorCodes.processor.errContractTypeNotSupported:
            return sTr("contract type not supported")
        case Constants.routerErrorCodes.processor.errFromChainNotSupported:
            return sTr("from chain not supported")
        case Constants.routerErrorCodes.processor.errToChainNotSupported:
            return sTr("to chain not supported")
        case Constants.routerErrorCodes.processor.errTxForChainNotSupported:
            return sTr("tx for chain not supported")
        case Constants.routerErrorCodes.processor.errENSResolverNotFound:
            return sTr("ens resolver not found")
        case Constants.routerErrorCodes.processor.errENSRegistrarNotFound:
            return sTr("ens registrar not found")
        case Constants.routerErrorCodes.processor.errToAndFromTokensMustBeSet:
            return sTr("to and from tokens must be set")
        case Constants.routerErrorCodes.processor.errCannotResolveTokens:
            return sTr("cannot resolve tokens")
        case Constants.routerErrorCodes.processor.errPriceRouteNotFound:
            return sTr("price route not found")
        case Constants.routerErrorCodes.processor.errConvertingAmountToBigInt:
            return sTr("converting amount issue")
        case Constants.routerErrorCodes.processor.errNoChainSet:
            return sTr("no chain set")
        case Constants.routerErrorCodes.processor.errNoTokenSet:
            return sTr("no token set")
        case Constants.routerErrorCodes.processor.errToTokenShouldNotBeSet:
            return sTr("to token should not be set")
        case Constants.routerErrorCodes.processor.errFromAndToChainsMustBeDifferent:
            return sTr("from and to chains must be different")
        case Constants.routerErrorCodes.processor.errFromAndToChainsMustBeSame:
            return sTr("from and to chains must be same")
        case Constants.routerErrorCodes.processor.errFromAndToTokensMustBeDifferent:
            return sTr("from and to tokens must be different")
        case Constants.routerErrorCodes.processor.errContextCancelled:
            return sTr("context cancelled")
        case Constants.routerErrorCodes.processor.errContextDeadlineExceeded:
            return sTr("context deadline exceeded")
        case Constants.routerErrorCodes.processor.errPriceTimeout:
            return sTr("fetching price timeout")
        case Constants.routerErrorCodes.processor.errNotEnoughLiquidity:
            return qsTr("not enough liquidity")
        case Constants.routerErrorCodes.processor.errPriceImpactTooHigh:
            return qsTr("price impact too high")

        case Constants.routerErrorCodes.processor.errTransferCustomError:
        case Constants.routerErrorCodes.processor.errERC721TransferCustomError:
        case Constants.routerErrorCodes.processor.errERC1155TransferCustomError:
        case Constants.routerErrorCodes.processor.errBridgeHopCustomError:
        case Constants.routerErrorCodes.processor.errBridgeCellerCustomError:
        case Constants.routerErrorCodes.processor.errSwapParaswapCustomError:
        case Constants.routerErrorCodes.processor.errENSRegisterCustomError:
        case Constants.routerErrorCodes.processor.errENSReleaseCustomError:
        case Constants.routerErrorCodes.processor.errENSPublicKeyCustomError:
        case Constants.routerErrorCodes.processor.errStickersBuyCustomError:
            return details
        case Constants.routerErrorCodes.router.errENSRegisterRequiresUsernameAndPubKey:
            return sTr("username and public key are required for registering ens name")
        case Constants.routerErrorCodes.router.errENSRegisterTestnetSTTOnly:
            return sTr("only STT is supported for registering ens name on testnet")
        case Constants.routerErrorCodes.router.errENSRegisterMainnetSNTOnly:
            return sTr("only SNT is supported for registering ens name on mainnet")
        case Constants.routerErrorCodes.router.errENSReleaseRequiresUsername:
            return sTr("username is required for releasing ens name")
        case Constants.routerErrorCodes.router.errENSSetPubKeyRequiresUsernameAndPubKey:
            return sTr("username and public key are required for setting public key")
        case Constants.routerErrorCodes.router.errStickersBuyRequiresPackID:
            return sTr("stickers pack id is required for buying stickers")
        case Constants.routerErrorCodes.router.errSwapRequiresToTokenID:
            return sTr("to token is required for Swap")
        case Constants.routerErrorCodes.router.errSwapTokenIDMustBeDifferent:
            return sTr("from and to token must be different")
        case Constants.routerErrorCodes.router.errSwapAmountInAmountOutMustBeExclusive:
            return sTr("only one of amount to send or receiving amount can be set")
        case Constants.routerErrorCodes.router.errSwapAmountInMustBePositive:
            return sTr("amount to send must be positive")
        case Constants.routerErrorCodes.router.errSwapAmountOutMustBePositive:
            return sTr("receiving amount must be positive")
        case Constants.routerErrorCodes.router.errLockedAmountNotSupportedForNetwork:
            return sTr("locked amount is not supported for the selected network")
        case Constants.routerErrorCodes.router.errLockedAmountNotNegative:
            return sTr("locked amount must not be negative")
        case Constants.routerErrorCodes.router.errLockedAmountExceedsTotalSendAmount:
            return sTr("locked amount exceeds the total amount to send")
        case Constants.routerErrorCodes.router.errLockedAmountLessThanSendAmountAllNetworks:
            return sTr("locked amount is less than the total amount to send, but all networks are locked")
        case Constants.routerErrorCodes.router.errNativeTokenNotFound:
            return sTr("native token not found")
        case Constants.routerErrorCodes.router.errDisabledChainFoundAmongLockedNetworks:
            return sTr("disabled chain found among locked networks")
        case Constants.routerErrorCodes.router.errENSSetPubKeyInvalidUsername:
            return sTr("a valid username, ending in '.eth', is required for setting public key")
        case Constants.routerErrorCodes.router.errLockedAmountExcludesAllSupported:
            return sTr("all supported chains are excluded, routing impossible")
        case Constants.routerErrorCodes.router.errTokenNotFound:
            return sTr("token not found")
        case Constants.routerErrorCodes.router.errNoBestRouteFound:
            return sTr("no best route found")
        case Constants.routerErrorCodes.router.errCannotCheckReceiverBalance:
            return sTr("cannot check balance")
        case Constants.routerErrorCodes.router.errCannotCheckLockedAmounts:
            return qsTr("cannot check locked amounts")
        case Constants.routerErrorCodes.router.errNotEnoughTokenBalance:
        case Constants.routerErrorCodes.router.errNotEnoughNativeBalance:
            try {
                const jsonObj = JSON.parse(details)

                let chain = Constants.openseaExplorerLinks.ethereum
                switch(jsonObj.chainId) {
                case Constants.chains.optimismChainId:
                    case Constants.chains.optimismSepoliaChainId:
                    chain = Constants.openseaExplorerLinks.optimism
                    break
                case Constants.chains.arbitrumChainId:
                    case Constants.chains.arbitrumSepoliaChainId:
                    chain = Constants.openseaExplorerLinks.arbitrum
                    break
                }

                return qsTr("not enough balance for %1 on %2 chain").arg(jsonObj.token).arg(chain)
            }
            catch (e) {
                return ""
            }
        case Constants.routerErrorCodes.router.errLowAmountInForHopBridge:
            return qsTr("bonder fee greater than estimated received, a higher amount is needed to cover fees")
        default:
            return ""
        }
    }
}
