import QtQuick 2.13

import utils 1.0

Item {
    id: root

    // @see src/app_service/service/token/async_tasks.nim BalanceHistoryTimeInterval
    enum TimeRange {
        Weekly = 0,
        Monthly,
        HalfYearly,
        Yearly,
        All
    }

    readonly property var timeRangeTabsModel: [
        {text: qsTr("7D"), enabled: true, timeRange: ChartStoreBase.TimeRange.Weekly},
        {text: qsTr("1M"), enabled: true, timeRange: ChartStoreBase.TimeRange.Monthly},
        {text: qsTr("6M"), enabled: true, timeRange: ChartStoreBase.TimeRange.HalfYearly},
        {text: qsTr("1Y"), enabled: true, timeRange: ChartStoreBase.TimeRange.Yearly},
        {text: qsTr("ALL"), enabled: true, timeRange: ChartStoreBase.TimeRange.All}]

    property var weeklyData: []
    property var monthlyData: []
    property var halfYearlyData: []
    property var yearlyData: []
    property var allData: []

    property var weeklyTimeRange: []
    property var monthlyTimeRange: []
    property var halfYearlyTimeRange: []
    property var yearlyTimeRange: []
    property var allTimeRange: []

    property int monthlyMaxTicks: monthlyTimeRange.length/d.hoursInADay
    property int weeklyMaxTicks: weeklyTimeRange.length/d.hoursInADay
    property int halfYearlyMaxTicks: halfYearlyTimeRange.length/d.avgLengthOfMonth
    property int yearlyMaxTicks: yearlyTimeRange.length/d.avgLengthOfMonth
    property int allTimeRangeTicks: 0

    // BEWARE that timeRange, dataRange and maxTicks properties are coupled with the timeRangeTabsModel order through
    // indexing. See StatusChartPanel.timeRangeTabBarIndex
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

    readonly property var maxTicks: [
        {'7D': weeklyMaxTicks},
        {'1M': monthlyMaxTicks},
        {'6M': halfYearlyMaxTicks},
        {'1Y': yearlyMaxTicks},
        {'ALL': allTimeRangeTicks}
    ]

    /// \timeRange is the time range of the data that was updated
    signal newDataReady(int timeRange)

    function timeRangeEnumToStr(enumVal) {
        return d.timeRangeTabsModel.get(enumVal)
    }
    function timeRangeStrToEnum(str) {
        return d.timeRangeStrToEnumMap.get(str)
    }

    /// \arg timeRange: of type ChartStoreBase.TimeRange
    function updateRequestTime(timeRange) {
        d.requestTimes.set(timeRange, new Date())
    }

    function resetRequestTime() {
        d.requestTimes.set(timeRange, new Date(0))
    }

    /// \arg timeRange: of type ChartStoreBase.TimeRange
    function isTimeToRequest(timeRange) {
        if(d.requestTimes.has(timeRange)) {
            const hoursToIgnore = 12
            let existing = d.requestTimes.get(timeRange)
            let willBeMs = new Date(existing.getTime() + (hoursToIgnore * 3600000))
            return new Date(willBeMs) < new Date()
        }
        else
            return true
    }

    QtObject {
        id: d

        readonly property int hoursInADay: 24
        readonly property int avgLengthOfMonth: 30
        property var timeRangeEnumToStrMap: null
        property var timeRangeStrToEnumMap: null
        property var requestTimes: null
    }

    Component.onCompleted: {
        if(d.timeRangeEnumToStrMap === null) {
            d.timeRangeEnumToStrMap = new Map()
            for (const x of timeRangeTabsModel) {
                d.timeRangeEnumToStrMap.set(x.timeRange, x.text)
            }
            d.timeRangeStrToEnumMap = new Map()
            for (const x of d.timeRangeEnumToStrMap.entries()) {
                let key = x[0]
                let val = x[1]
                d.timeRangeStrToEnumMap.set(val, key)
            }
        }
        if(d.requestTimes === null) {
            d.requestTimes = new Map()
        }
    }
}