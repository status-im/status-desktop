import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Slider {
    id: statusSlider

    implicitWidth: 360
    implicitHeight: 4

    leftPadding: 0

    background: Rectangle {
        implicitHeight: 4
        implicitWidth: 100
        color: {
            if (statusSlider.value === statusSlider.to) {
                return Theme.palette.primaryColor1
            }
            return Theme.palette.primaryColor3
        }
        radius: 2
        Rectangle {
            radius: 2
            anchors.fill: parent
            visible: statusSlider.value > statusSlider.from && statusSlider.value < statusSlider.to
            gradient: Gradient {
                GradientStop { color: Theme.palette.primaryColor1 ; position: 0 }
                GradientStop { color: Theme.palette.primaryColor3 ; position: (((statusSlider.value - statusSlider.from) * 100) / (statusSlider.to - statusSlider.from) / 100).toFixed(2) }
                GradientStop { color: Theme.palette.primaryColor1 ; position: (((statusSlider.value - statusSlider.from) * 100) / (statusSlider.to - statusSlider.from) / 100).toFixed(2) }
                GradientStop { color: Theme.palette.primaryColor3 ; position: 1 }
                orientation: Gradient.Horizontal
            }
        }
    } // background

    handle: Rectangle {
        x: statusSlider.leftPadding + statusSlider.visualPosition * (statusSlider.availableWidth - width / 2)
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.palette.white
        implicitWidth: 28
        implicitHeight: 28
        radius: 14
        layer.enabled: true
        layer.effect: DropShadow {
            width: parent.width
            height: parent.height
            visible: true
            verticalOffset: 2
            samples: 15
            fast: true
            cached: true
            color: Theme.palette.dropShadow
        }
    }
}
