import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Controls 0.1

import "private/chart"

/*!
     \qmltype StatusChartPanel
     \inherits Page
     \inqmlmodule StatusQ.Components
     \since StatusQ.Components 0.1
     \brief Displays a chart component together with an optional header in order to add a list of options.
     Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-page.html}{Page}.

     The \c StatusChartPanel displays a customizable chart component. Additionally, options
     can be added in the header in both right and left sides given graphTabsModel and timeRangeTabsModel
     property are set respectively.

     For example:

     \qml
     StatusChartPanel {
        id: graphDetail
        width: parent.width
        height: 290
        anchors.verticalCenter: parent.verticalCenter
        graphsModel: d.graphTabsModel
        timeRangeModel: d.timeRangeTabsModel
        chart.chartType: 'line'
        chart.chartData: {
            return {
                datasets: [{
                    data: d.data
                }],
                ...
            }
        }
        chart.chartOptions: {
            return {
                legend: {
                    display: false
                },
                ...
            }
        }
    }
    \endqml

    \image status_chart_panel.png

    For a list of components available see StatusQ.
*/

Page {
    id: root

    /*!
        \qmlproperty var StatusChartPanel::graphsModel
        This property holds the graphs model options to be set on the left side tab bar of the header.
    */
    property var graphsModel
    /*!
        \qmlproperty var StatusChartPanel::timeRangeModel
        This property holds the time range options to be set on the right side tab bar of the header.
    */
    property var timeRangeModel

    /*!
        \qmlproperty alias StatusChartPanel::graphComponent
        This property holds holds a reference to the graph component.
    */
    property alias chart: graphComponent

    /*!
        \qmlproperty alias StatusChartPanel::timeRangeTabBarIndex
        This property holds holds a reference to the time range tab bar current index.
    */
    property alias timeRangeTabBarIndex: timeRangeTabBar.currentIndex

    /*!
        \qmlproperty string StatusChartPanel::selectedTimeRange
        This property holds holds the text of the current time range tab bar selected tab.
    */
    property string selectedTimeRange: timeRangeTabBar.currentItem.text

    /*!
        \qmlsignal
        This signal is emitted when a header tab bar is clicked.
    */
    signal headerTabClicked(string text)

    Component {
        id: tabButton
        StatusTabButton {
            leftPadding: 0
            width: implicitWidth
            onClicked: {
                root.headerTabClicked(text);
            }
        }
    }

    Component.onCompleted: {
        if (!!timeRangeModel) {
            for (var i = 0; i < timeRangeModel.length; i++) {
                var timeTab = tabButton.createObject(root, { text: timeRangeModel[i].text,
                                                             enabled: timeRangeModel[i].enabled });
                timeRangeTabBar.addItem(timeTab);
            }
        }
        if (!!graphsModel) {
            for (var j = 0; j < graphsModel.length; j++) {
                var graphTab = tabButton.createObject(root, { text: graphsModel[j].text,
                                                              enabled: graphsModel[j].enabled });
                graphsTabBar.addItem(graphTab);
            }
        }
    }

    background: null
    header: Item {
        height: childrenRect.height
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            StatusTabBar {
                id: graphsTabBar
            }
            StatusTabBar {
                id: timeRangeTabBar
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    contentItem: Item {
        Chart {
            id: graphComponent
            anchors.fill: parent
        }
    }
}
