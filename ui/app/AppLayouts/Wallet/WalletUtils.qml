pragma Singleton

import QtQuick 2.14

import utils 1.0
import StatusQ.Core.Theme 0.1

import StatusQ.Core.Utils 0.1 as StatusQUtils

import "stores" as WalletStores

QtObject {
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
        if (symbol !== Constants.ethToken) {
            return value
        }

        return value - Math.max(0.0001, Math.min(0.01, value * 0.1))
    }
}
