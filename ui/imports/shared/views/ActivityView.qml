import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../panels"
import "../popups"
import "../stores"
import "../controls"

// Temporary developer view to test the filter APIs
Item {
    id: root

    property var controller

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            id: filterLayout

            readonly property int millisInADay: 24 * 60 * 60 * 1000
            property int start: fromSlider.value > 0 ? Math.floor(new Date(new Date() - (fromSlider.value * millisInADay)).getTime() / 1000) : 0
            property int end: toSlider.value > 0 ? Math.floor(new Date(new Date() - (toSlider.value * millisInADay)).getTime() / 1000) : 0

            function updateFilter() { controller.updateFilter(start, end) }

            RowLayout {
                Label { text: "Past Days Span: 100" }
                Slider {
                    id: fromSlider

                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50

                    from: 100
                    to: 0

                    stepSize: 1
                    value: 0

                    onPressedChanged: { if (!pressed) filterLayout.updateFilter() }
                }
                Label { text: `${fromSlider.value}d - ${toSlider.value}d` }
                Slider {
                    id: toSlider

                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50

                    enabled: fromSlider.value > 1

                    from: fromSlider.value - 1
                    to: 0

                    stepSize: 1
                    value: 0

                    onPressedChanged: { if (!pressed) filterLayout.updateFilter() }
                }
                Label { text: "0" }
            }
            Label { text: `Interval: ${filterLayout.start > 0 ? root.epochToDateStr(filterLayout.start) : "all time"} - ${filterLayout.end > 0 ? root.epochToDateStr(filterLayout.end) : "now"}` }
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: controller.model

            delegate: Item {
                width: parent ? parent.width : 0
                height: itemLayout.implicitHeight

                readonly property var entry: model.activityEntry

                RowLayout {
                    id: itemLayout
                    anchors.fill: parent

                    Label { text: entry.isMultiTransaction ? "MT" : entry.isPendingTransaction ? "PT" : " T" }
                    Label { text: `[${root.epochToDateStr(entry.timestamp)}] ` }
                    Label { text: entry.isMultiTransaction ? entry.fromAmount : entry.amount }
                    Label { text: "from"; Layout.leftMargin: 5; Layout.rightMargin: 5 }
                    Label { text: entry.sender; Layout.maximumWidth: 200; elide: Text.ElideMiddle }
                    Label { text: "to"; Layout.leftMargin: 5; Layout.rightMargin: 5 }
                    Label { text: entry.recipient; Layout.maximumWidth: 200; elide: Text.ElideMiddle }
                    Label { text: "got"; Layout.leftMargin: 5; Layout.rightMargin: 5; visible: entry.isMultiTransaction }
                    Label { text: entry.toAmount; Layout.leftMargin: 5; Layout.rightMargin: 5; visible: entry.isMultiTransaction }
                    RowLayout {}    // Spacer
                }
            }
        }
    }

    function epochToDateStr(epochTimestamp) {
        var date = new Date(epochTimestamp * 1000);
        return date.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm");
    }
}
