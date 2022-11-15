import QtQuick 2.13

import StatusQ.Core 0.1

import utils 1.0

ChartStoreBase {
    id: root

    readonly property alias address: d.address
    readonly property alias tokenSymbol: d.tokenSymbol
    readonly property alias currencySymbol: d.currencySymbol

    QtObject {
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

    /// \arg timeRange: of type ChartStoreBase.TimeRange
    function setData(address, tokenSymbol, currencySymbol, timeRange, timeRangeData, balanceData) {
        switch(timeRange) {
            case ChartStoreBase.TimeRange.Weekly:
                root.weeklyData = balanceData
                root.weeklyTimeRange = timeRangeData
                root.weeklyMaxTicks = 0
            break;
            case ChartStoreBase.TimeRange.Monthly:
                root.monthlyData = balanceData
                root.monthlyTimeRange = timeRangeData
                root.monthlyMaxTicks = 0
            break;
            case ChartStoreBase.TimeRange.HalfYearly:
                root.halfYearlyData = balanceData
                root.halfYearlyTimeRange = timeRangeData
                root.halfYearlyMaxTicks = 0
            break;
            case ChartStoreBase.TimeRange.Yearly:
                root.yearlyData = balanceData
                root.yearlyTimeRange = timeRangeData
                root.yearlyMaxTicks = 0
            break;
            case ChartStoreBase.TimeRange.All:
                root.allData = balanceData
                root.allTimeRange = timeRangeData
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
        for (let tR = ChartStoreBase.TimeRange.Weekly; tR <= ChartStoreBase.TimeRange.All; tR++) {
            root.setData(address, tokenSymbol, currencySymbol, tR, [], [])
        }
    }

    Connections {
        target: walletSectionAllTokens

        function onTokenBalanceHistoryDataReady(balanceHistoryJson: string) {
            // chainIds, address, tokenSymbol, currencySymbol, timeInterval
            let response = JSON.parse(balanceHistoryJson)
            if(typeof response.error !== "undefined") {
                console.warn("error in balance history: " + response.error)
                return
            }

            if(d.address != response.address || d.tokenSymbol != response.tokenSymbol || d.currencySymbol != response.currencySymbol) {
                root.resetAllData(response.address, response.tokenSymbol, response.currencySymbol)
            }

            if(typeof response.historicalData === "undefined" || response.historicalData === null || response.historicalData.length == 0) {
                console.info("no data in balance history")
                return
            }

            var tmpTimeRange = []
            var tmpDataValues = []
            for(let i = 0; i < response.historicalData.length; i++) {
                let dataEntry = response.historicalData[i]

                let dateString = response.timeInterval == ChartStoreBase.TimeRange.Weekly || response.timeInterval == ChartStoreBase.TimeRange.Monthly
                    ? LocaleUtils.getDayMonth(dataEntry.time * 1000)
                    : LocaleUtils.getMonthYear(dataEntry.time * 1000)
                tmpTimeRange.push(dateString)

                tmpDataValues.push(dataEntry.value)
            }

            root.setData(response.address, response.tokenSymbol, response.currencySymbol, response.timeInterval, tmpTimeRange, tmpDataValues)
        }
    }
}
