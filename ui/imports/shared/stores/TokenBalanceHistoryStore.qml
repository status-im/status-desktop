import QtQuick 2.13

import StatusQ.Core 0.1

import utils 1.0

ChartStoreBase {
    id: root

    /*required*/ property string address: ""

    /// \arg timeRange: of type ChartStoreBase.TimeRange
    function setData(timeRange, timeRangeData, balanceData) {
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
            break;
        }
        root.newDataReady(timeRange)
    }

    /// \arg timeRange: of type ChartStoreBase.TimeRange
    function resetData(timeRange) {
        root.setData(timeRange, [], [])
    }

    Connections {
        target: walletSectionAllTokens
        function onTokenBalanceHistoryDataReady(balanceHistory: string) {
           // chainId, address, symbol, timeInterval
            let response = JSON.parse(balanceHistory)
            if (response === null) {
                console.warn("error parsing balance history json message data")
                root.resetRequestTime()
                return
            }

            if(typeof response.historicalData === "undefined" || response.historicalData === null || response.historicalData.length == 0) {
                console.warn("error no data in balance history. Must be an error from status-go")
                root.resetRequestTime()
                return
            } else if(response.address !== root.address) {
                // Ignore data for other addresses. Will be handled by other instances of this store
                return
            }

            root.resetData(response.timeInterval)

            var tmpTimeRange = []
            var tmpDataValues = []
            for(let i = 0; i < response.historicalData.length; i++) {
                let dataEntry = response.historicalData[i]

                let dateString = response.timeInterval == ChartStoreBase.TimeRange.Weekly || response.timeInterval == ChartStoreBase.TimeRange.Monthly
                    ? LocaleUtils.getDayMonth(dataEntry.time * 1000)
                    : LocaleUtils.getMonthYear(dataEntry.time * 1000)
                tmpTimeRange.push(dateString)

                tmpDataValues.push(parseFloat(globalUtils.wei2Eth(dataEntry.value, 18)))
            }

            root.setData(response.timeInterval, tmpTimeRange, tmpDataValues)
            root.updateRequestTime(response.timeInterval)
        }
    }
}
