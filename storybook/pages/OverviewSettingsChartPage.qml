import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.panels 1.0
import Models 1.0

SplitView {

    OverviewSettingsChart {
        id: chart
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        model: generateRandomModel()
    }

    function generateRandomModel() {
        var newModel = []
        const now = Date.now()
        for(var i = 0; i < 500000; i++) {
            var date = generateRandomDate(1463154962000, now)
            newModel.push(date)
        }
        return newModel
    }

    function generateRandomDate(from, to) {
      return from + Math.random() * (to - from)
    }
}
