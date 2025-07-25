import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

Item {

    ColumnLayout {
        anchors.centerIn: parent

        StatusBaseText {
            text: qsTr("Thickness")
        }

        StatusSlider {
            id: thicknessSlider
            from: colorSpace.width / 8
            to: colorSpace.width / 16
            value: colorSpace.width / 10
            Layout.fillWidth: true
        }

        StatusBaseText {
            text: qsTr("Min saturate: ") + colorSpace.minSaturate.toFixed(2)
        }

        StatusSlider {
            id: minSatSlider
            from: 0
            to: 0.5
            value: 0
            Layout.fillWidth: true
        }

        StatusBaseText {
            text: qsTr("Max saturate: ") + colorSpace.maxSaturate.toFixed(2)
        }

        StatusSlider {
            id: maxSatSlider
            from: 0.51
            to: 1.0
            value: 1.0
            Layout.fillWidth: true
        }

        StatusBaseText {
            text: qsTr("Min value: ") + colorSpace.minValue.toFixed(2)
        }

        StatusSlider {
            id: minValSlider
            from: 0
            to: 0.5
            value: 0
            Layout.fillWidth: true
        }

        StatusBaseText {
            text: qsTr("Max value: ") + colorSpace.maxValue.toFixed(2)
        }

        StatusSlider {
            id: maxValSlider
            from: 0.51
            to: 1.0
            value: 1.0
            Layout.fillWidth: true
        }

        StatusColorSpace {
            id: colorSpace
            color: "#ed77eb"
            thickness: thicknessSlider.value
            minSaturate: minSatSlider.value
            maxSaturate: maxSatSlider.value
            minValue: minValSlider.value
            maxValue: maxValSlider.value
        }

        StatusBaseText {
            text: qsTr("Color") + ": " + colorSpace.color
        }

        Rectangle {
            color: colorSpace.color
            implicitHeight: 48
            radius: 10
            Layout.fillWidth: true

            StatusBaseText {
                anchors.centerIn: parent
                color: Theme.palette.white
                font.pixelSize: Theme.primaryTextFontSize
                text: "Quick brown fox jumps over the lazy dog"
            }
        }

        StatusButton {
            text: "Randomize"
            onPressed: colorSpace.color = Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
        }
    }
}
