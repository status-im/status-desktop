import QtQuick 2.15

import StatusQ.Core 0.1

import utils 1.0

ChartDataBase {
    id: root

    function setTimeAndValueData(data, range) {
        var marketValues = []
        var timeRanges = []
        for (var i = 0; i < data.length; ++i) {
            marketValues[i] = data[i].close;

            timeRanges[i] = range === ChartDataBase.TimeRange.Weekly || range === ChartDataBase.TimeRange.Monthly ?
                        LocaleUtils.getDayMonth(data[i].time * 1000):
                        LocaleUtils.getMonthYear(data[i].time * 1000)
        }

        switch(range) {
        case ChartDataBase.TimeRange.Weekly: {
            weeklyData = marketValues
            weeklyTimeRange = timeRanges
            break
        }
        case ChartDataBase.TimeRange.Monthly: {
            monthlyData = marketValues
            monthlyTimeRange = timeRanges
            break
        }
        case ChartDataBase.TimeRange.HalfYearly: {
            halfYearlyData = marketValues
            halfYearlyTimeRange = timeRanges
            break
        }
        case ChartDataBase.TimeRange.Yearly: {
            yearlyData = marketValues
            yearlyTimeRange = timeRanges
            break
        }
        case ChartDataBase.TimeRange.All: {
            allData = marketValues
            allTimeRange = timeRanges
            if(data.length > 0)
                allTimeRangeTicks = Math.abs(Qt.formatDate(new Date(data[0].time*1000), 'yyyy') - Qt.formatDate(new Date(data[data.length-1].time*1000), 'yyyy'))
            break
        }
        }
    }
}
