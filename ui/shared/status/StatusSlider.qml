import QtQuick 2.13
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.13
import QtQuick.Controls 1.4 as QQC1
import "../../imports"

QQC1.Slider {
    id: slider
    anchors.left: parent.left
    anchors.right: parent.right
    style: SliderStyle {
        groove: Rectangle {
            implicitHeight: 4
            color: {
                if (control.value === control.maximumValue) {
                    return Style.current.blue
                }
                return Style.current.lightBlue
            }
            radius: 10
            Rectangle {
                radius: 10
                anchors.fill: parent
                visible: control.value > control.minimumValue && control.value < control.maximumValue
                gradient: Gradient {
                    GradientStop { color: Style.current.blue ; position: 0 }
                    GradientStop { color: Style.current.lightBlue ; position: (((control.value - control.minimumValue)*100)/(control.maximumValue - control.minimumValue)/100).toFixed(2) }
                    GradientStop { color: Style.current.blue ; position: (((control.value - control.minimumValue)*100)/(control.maximumValue - control.minimumValue)/100).toFixed(2) }
                    GradientStop { color: Style.current.lightBlue ; position: 1 }
                    orientation: Gradient.Horizontal
                }
            }
        }
        handle: Rectangle {
            anchors.centerIn: parent
            color: control.pressed ? Style.current.grey : Style.current.white
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
                color: "#22000000"
            }
        }
    }
}
