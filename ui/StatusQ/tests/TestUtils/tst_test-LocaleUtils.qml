import QtQuick 2.15
import QtTest 1.15

import StatusQ.Core 0.1

TestCase {
    id: testCase

    name: "LocaleUtils"

    function test_currencyAmountToLocaleString_data() {
        function currencyAmount(amount, displayDecimals, stripTrailingZeroes, symbol) {
            return { amount, displayDecimals, stripTrailingZeroes, symbol }
        }

        return [
            {
                amount: null,
                amountString: "N/A"
            },
            {
                amount: "",
                amountString: "N/A"
            },
            {
                amount: "string",
                amountString: "N/A"
            },
            {
                amount: {},
                amountString: "N/A"
            },
            {
                amount: { amount: 4 },
                amountString: "4"
            },
            {
                amount: currencyAmount(1, 4, false, "ETH"),
                amountString: "1.0000 ETH"
            },
            {
                amount: currencyAmount(1.00001, 4, false, "ETH"),
                amountString: "1.0000 ETH"
            },
            {
                amount: currencyAmount(1.00009, 4, false, "ETH"),
                amountString: "1.0001 ETH"
            },
            {
                amount: currencyAmount(1.00005, 4, false, "ETH"),
                amountString: "1.0001 ETH"
            },
            {
                amount: currencyAmount(1, 4, true, "ETH"),
                amountString: "1 ETH"
            },
            {
                amount: currencyAmount(1.00001, 4, true, "ETH"),
                amountString: "1 ETH"
            },
            {
                amount: currencyAmount(1.00009, 4, true, "ETH"),
                amountString: "1.0001 ETH"
            },
            {
                amount: currencyAmount(1.00005, 4, true, "ETH"),
                amountString: "1.0001 ETH"
            },
            {
                amount: currencyAmount(1, 0, false, "ETH"),
                amountString: "1 ETH"
            },
            {
                amount: currencyAmount(1.4, 0, false, "ETH"),
                amountString: "1 ETH"
            },
            {
                amount: currencyAmount(1.5, 0, false, "ETH"),
                amountString: "2 ETH"
            },
            {
                amount: currencyAmount(1.8, 0, false, "ETH"),
                amountString: "2 ETH"
            },
            {
                amount: currencyAmount(1, 4, true, "ETH"),
                amountString: "1 ETH"
            },
            {
                amount: currencyAmount(100000000000, 4, false, "ETH"),
                amountString: "100.00B ETH"
            },
            {
                amount: currencyAmount(1000000, 4, true, "ETH"),
                amountString: "1,000,000 ETH"
            },
            {
                amount: currencyAmount(100000000000, 4, true, "ETH"),
                amountString: "100B ETH"
            },
            {
                amount: currencyAmount(0.0009, 4, true, "ETH"),
                amountString: "0.0009 ETH"
            },
            {
                amount: currencyAmount(0.0009, 3, true, "ETH"),
                amountString: "<0.001 ETH"
            },
            {
                amount: currencyAmount(0.0009, 1, true, "ETH"),
                amountString: "<0.1 ETH"
            },
            {
                amount: currencyAmount(0.0009, 0, true, "ETH"),
                amountString: "<1 ETH"
            }
        ]
    }

    function test_currencyAmountToLocaleString(data) {
        const locale = Qt.locale("en_US")

        compare(LocaleUtils.currencyAmountToLocaleString(
                    data.amount, null, locale), data.amountString)
    }
}
