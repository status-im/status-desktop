import QtQuick 2.13

import utils 1.0

QtObject {
    id: root


    enum TimeRange {
        Weekly = 0,
        Monthly,
        HalfYearly,
        Yearly,
        All
    }

    readonly property int hoursInADay: 24
    readonly property int avgLengthOfMonth: 30

    readonly property var graphTabsModel: [{text: qsTr("Price"), enabled: true}, {text: qsTr("Balance"), enabled: false}]
    readonly property var timeRangeTabsModel: [{text: qsTr("7D"), enabled: true},
        {text: qsTr("1M"), enabled: true}, {text: qsTr("6M"), enabled: true},
        {text: qsTr("1Y"), enabled: true}, {text: qsTr("ALL"), enabled: true}]

    property var weeklyData
    property var monthlyData
    property var halfYearlyData
    property var yearlyData
    property var allData

    property var weeklyTimeRange
    property var monthlyTimeRange
    property var halfYearlyTimeRange
    property var yearlyTimeRange
    property var allTimeRange

    readonly property var timeRange: [
        {'7D': weeklyTimeRange},
        {'1M': monthlyTimeRange},
        {'6M': halfYearlyTimeRange},
        {'1Y': yearlyTimeRange},
        {'ALL': allTimeRange}
    ]

    readonly property var dataRange: [
        {'7D': weeklyData},
        {'1M': monthlyData},
        {'6M': halfYearlyData},
        {'1Y': yearlyData},
        {'ALL': allData}
    ]

    property int allTimeRangeTicks: 0

    readonly property var maxTicks: [
        {'7D': weeklyTimeRange.length/hoursInADay},
        {'1M': monthlyTimeRange.length/hoursInADay},
        {'6M': halfYearlyTimeRange.length/avgLengthOfMonth},
        {'1Y': yearlyTimeRange.length/avgLengthOfMonth},
        {'ALL': allTimeRangeTicks}
    ]

    function setTimeAndValueData(data, range) {
        var marketValues = []
        var timeRanges = []
        for (var i = 0; i < data.length; ++i) {
            marketValues[i] = data[i].close;

            timeRanges[i] = range === TokenMarketValuesStore.TimeRange.Weekly || range === TokenMarketValuesStore.TimeRange.Monthly ?
                        Utils.getDayMonth(data[i].time * 1000, RootStore.accountSensitiveSettings.is24hTimeFormat):
                        Utils.getMonthYear(data[i].time * 1000)
        }

        switch(range) {
        case TokenMarketValuesStore.TimeRange.Weekly: {
            weeklyData = marketValues
            weeklyTimeRange = timeRanges
            break
        }
        case TokenMarketValuesStore.TimeRange.Monthly: {
            monthlyData = marketValues
            monthlyTimeRange = timeRanges
            break
        }
        case TokenMarketValuesStore.TimeRange.HalfYearly: {
            halfYearlyData = marketValues
            halfYearlyTimeRange = timeRanges
            break
        }
        case TokenMarketValuesStore.TimeRange.Yearly: {
            yearlyData = marketValues
            yearlyTimeRange = timeRanges
            break
        }
        case TokenMarketValuesStore.TimeRange.All: {
            allData = marketValues
            allTimeRange = timeRanges
            if(data.length > 0)
                allTimeRangeTicks = Math.abs(Qt.formatDate(new Date(data[0].time*1000), 'yyyy') - Qt.formatDate(new Date(data[data.length-1].time*1000), 'yyyy'))
            break
        }
        }
    }
}
