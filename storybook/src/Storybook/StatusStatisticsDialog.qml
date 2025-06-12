import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtModelsToolkit 1.0

import Storybook 1.0
import utils 1.0

Dialog {
    id: root

    required property var pagesModel

    readonly property string contributingMdLink:
        "https://github.com/status-im/status-desktop/blob/master/" +
        "CONTRIBUTING.md#page-classification"

    anchors.centerIn: Overlay.overlay
    width: 420

    title: "Page status statistics"
    standardButtons: Dialog.Ok
    modal: true

    QtObject {
        id: d

        readonly property int total: root.pagesModel.ModelCount.count

        function percent(val) {
            return (val / total * 100).toFixed(2)
        }
    }

    contentItem: ColumnLayout {
        Label {
            Layout.bottomMargin: 20

            text: `Total number of pages: ${d.total}`
        }

        Repeater {
            model: [
                { status: "good", color: "green" },
                { status: "decent", color: "orange" },
                { status: "bad", color: "red" },
                { status: "uncategorized", color: "gray" }
            ]

            Row {
                spacing: 10

                Rectangle {
                    readonly property int size: label.height - 2

                    width: size
                    height: size
                    radius: size / 2
                    color: modelData.color
                }

                Label {
                    id: label

                    readonly property string status: modelData.status
                    readonly property int count: statusAggregator[status]

                    text: `${status}: ${count} (${d.percent(count)}%)`
                }
            }
        }

        Label {
            Layout.topMargin: 20

            text: `For details check <a href="${root.contributingMdLink}">CONTRIBUTING.md</a>`
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

    FunctionAggregator {
        id: statusAggregator

        readonly property int bad: value.bad
        readonly property int decent: value.decent
        readonly property int good: value.good
        readonly property int uncategorized: value.uncategorized

        model: root.pagesModel
        roleName: "status"

        initialValue: ({
            bad: 0,
            decent: 0,
            good: 0,
            uncategorized: 0
        })

        aggregateFunction: (aggr, value) => {
            let { bad, decent, good, uncategorized } = aggr

            switch (value) {
                case PagesModel.Bad: bad++; break
                case PagesModel.Decent: decent++; break
                case PagesModel.Good: good++; break
                default: uncategorized++
            }

            return { bad, decent, good, uncategorized }
        }
    }
}
