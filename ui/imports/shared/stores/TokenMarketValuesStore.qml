import QtQuick 2.13

import StatusQ.Core 0.1

import utils 1.0

ChartStoreBase {
    id: root

    function setTimeAndValueData(data, range) {
        var marketValues = []
        var timeRanges = []
        for (var i = 0; i < data.length; ++i) {
            marketValues[i] = data[i].close;

            timeRanges[i] = range === ChartStoreBase.TimeRange.Weekly || range === ChartStoreBase.TimeRange.Monthly ?
                        LocaleUtils.getDayMonth(data[i].time * 1000):
                        LocaleUtils.getMonthYear(data[i].time * 1000)
        }

        switch(range) {
        case ChartStoreBase.TimeRange.Weekly: {
            weeklyData = marketValues
            weeklyTimeRange = timeRanges
            break
        }
        case ChartStoreBase.TimeRange.Monthly: {
            monthlyData = marketValues
            monthlyTimeRange = timeRanges
            break
        }
        case ChartStoreBase.TimeRange.HalfYearly: {
            halfYearlyData = marketValues
            halfYearlyTimeRange = timeRanges
            break
        }
        case ChartStoreBase.TimeRange.Yearly: {
            yearlyData = marketValues
            yearlyTimeRange = timeRanges
            break
        }
        case ChartStoreBase.TimeRange.All: {
            allData = marketValues
            allTimeRange = timeRanges
            if(data.length > 0)
                allTimeRangeTicks = Math.abs(Qt.formatDate(new Date(data[0].time*1000), 'yyyy') - Qt.formatDate(new Date(data[data.length-1].time*1000), 'yyyy'))
            break
        }
        }
    }
}
