pragma Singleton

import QtQuick 2.14

import utils 1.0
import StatusQ.Core.Theme 0.1

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
}
