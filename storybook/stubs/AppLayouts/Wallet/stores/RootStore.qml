// This should not be a singleton. TODO: Remove it once the "real" Wallet root store is not a singleton anymore.
pragma Singleton

import QtQml 2.15

QtObject {
    id: root

    // TODO: Remove this. This stub should be empty. The color transformation should be done in adaptors or in the first model transformation steps.
    function colorForChainShortName(chainShortName) {
        return "#FF0000" // Just some random testing color
    }
}
