import QtQml

import utils

ChartDataBase {
    id: root

    readonly property alias address: d.address
    readonly property alias tokenSymbol: d.tokenSymbol
    readonly property alias currencySymbol: d.currencySymbol

    readonly property QtObject _d: QtObject {
        id: d

        // Data identity received from backend
        property var chainIds: []
        property string address
        property string tokenSymbol
        property string currencySymbol
    }

    function hasData(address, tokenSymbol, currencySymbol, timeRangeEnum) {
        return address === d.address && tokenSymbol === d.tokenSymbol && currencySymbol === d.currencySymbol
                && root.dataRange[root.timeRangeEnumToTimeIndex(timeRangeEnum)][root.timeRangeEnumToStr(timeRangeEnum)].length > 0
    }

    /// \arg timeRange: of type ChartDataBase.TimeRange
    function setData(address, tokenSymbol, currencySymbol, timeRange, timeRangeData, balanceData) {
        switch(timeRange) {
            case ChartDataBase.TimeRange.Weekly:
                root.weeklyData = balanceData
                root.weeklyMaxTicks = 0
            break;
            case ChartDataBase.TimeRange.Monthly:
                root.monthlyData = balanceData
                root.monthlyMaxTicks = 0
            break;
            case ChartDataBase.TimeRange.HalfYearly:
                root.halfYearlyData = balanceData
                root.halfYearlyMaxTicks = 0
            break;
            case ChartDataBase.TimeRange.Yearly:
                root.yearlyData = balanceData
                root.yearlyMaxTicks = 0
            break;
            case ChartDataBase.TimeRange.All:
                root.allData = balanceData
                root.allTimeRangeTicks = 0
            break;
            default:
                console.warn("Invalid or unsupported time range")
                return
        }

        d.address = address
        d.tokenSymbol = tokenSymbol
        d.currencySymbol = currencySymbol

        root.newDataReady(address, tokenSymbol, currencySymbol, timeRange)
    }

    function resetAllData(address, tokenSymbol, currencySymbol) {
        for (let tR = ChartDataBase.TimeRange.Weekly; tR <= ChartDataBase.TimeRange.All; tR++) {
            root.setData(address, tokenSymbol, currencySymbol, tR, [], [])
        }
    }

    readonly property Connections _c: Connections {
        target: walletSectionAllTokens

        function onTokenBalanceHistoryDataReady(balanceHistoryJson: string) {
            // chainIds, address, tokenSymbol, currencySymbol, timeInterval
            let response = JSON.parse(balanceHistoryJson)
            if(typeof response.error !== "undefined") {
                console.warn("error in balance history: " + response.error)
                return
            }

            if (response.addresses.length > 1) {
                response.address = ""
            } else {
                response.address = response.addresses[0]
            }

            if(d.address != response.address || d.tokenSymbol != response.tokenSymbol || d.currencySymbol != response.currencySymbol) {
                root.resetAllData(response.address, response.tokenSymbol, response.currencySymbol)
            }

            if(typeof response.historicalData === "undefined" || response.historicalData === null || response.historicalData.length == 0) {
                console.info("no data in balance history")
                return
            }

            var tmpDataValues = []
            for(let i = 0; i < response.historicalData.length; i++) {
                let dataEntry = response.historicalData[i]
                tmpDataValues.push({ x: new Date(dataEntry.time * 1000), y: dataEntry.value })
            }

            root.setData(response.address, response.tokenSymbol, response.currencySymbol, response.timeInterval, [], tmpDataValues)
        }
    }
}
