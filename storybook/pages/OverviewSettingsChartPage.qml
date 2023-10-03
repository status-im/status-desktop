import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.panels 1.0
import Models 1.0

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    OverviewSettingsChart {
        id: chart
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        onCollectCommunityMetricsMessagesCount: generateRandomModel(intervals)
    }

    function generateRandomModel(intervalsStr) {
        if(!intervalsStr) return

        var response = {
            communityId: "",
            metricsType: timestampMetrics.checked ? "MessagesTimestamps" : "MessagesCount",
            intervals: []
        }

        var intervals = JSON.parse(intervalsStr)

        response.intervals = intervals.map( x => {
            var timestamps = generateRandomDate(x.startTimestamp, x.endTimestamp, Math.random() * 10)

            return {
                startTimestamp: x.startTimestamp,
                endTimestamp: x.endTimestamp,
                timestamps: timestamps,
                count: timestamps.length
            }
        })

        chart.model = response
    }

    function generateRandomDate(from, to, count) {
        var newModel = []
        for(var i = 0; i < count; i++) {
            var date = from + Math.random() * (to - from)
            newModel.push(date)
        }
        return newModel
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        CheckBox {
            id: timestampMetrics
            text: "Metrics using timestamps"
            checked: false
            onCheckedChanged: chart.reset()
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?type=design&node-id=31281-635619&mode=design&t=RYpVRgwqCjp8fUEX-0
