import QtQuick 2.8
import QtCharts 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

ApplicationWindow {
    width: 400
    height: 300
    title: "Charts"

    Component.onCompleted: visible = true

    ColumnLayout {
	anchors.fill: parent

	ChartView {
            id: view

	    Layout.fillHeight: true
	    Layout.fillWidth: true

            VXYModelMapper {
		id: mapper
		model: myListModel
		series: lineSeries
		xColumn: 0
		yColumn: 1
            }

            LineSeries {
		id: lineSeries
		name: "LineSeries"
		axisX: ValueAxis {
		    min: 0
		    max: myListModel.maxX
		}
		axisY: ValueAxis {
		    min: 0
		    max: myListModel.maxY
		}
            }
	}

	RowLayout {
	    Layout.fillWidth: true

	    Button {
		text: "Add random point"
		onClicked: myListModel.addRandomPoint()
	    }
	}
    }
}
