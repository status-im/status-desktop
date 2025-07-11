import QtQuick

import utils

ListModel {
    ListElement {
        address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
        valid: true
    }
    ListElement {
        address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756ccx"
        valid: false
    }

    function addAddressesFromString(addresses) {
        const words = addresses.trim().split(/[\s+,]/)
        const existing = new Set()

        for (let i = 0; i < count; i++)
            existing.add(get(i).address)

        words.forEach(word => {
            if (word === "" || existing.has(word))
                return

            const valid = Utils.isValidAddress(word)
            append({ valid, address: word })
        })
    }
}
