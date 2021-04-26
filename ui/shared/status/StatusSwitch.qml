import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Switch {
    id: control

    indicator: Rectangle {
        id: oval
        implicitWidth: 52 * scaleAction.factor
        implicitHeight: 28 * scaleAction.factor
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 14
        color: control.checked ? Style.current.primary : Style.current.inputBackground

        Rectangle {
            id: circle
            y: 4
            width: 20 * scaleAction.factor
            height: 20 * scaleAction.factor
            radius: 10
            color: Style.current.white
            layer.enabled: true
            layer.effect: DropShadow {
                width: parent.width
                height: parent.height
                visible: true
                verticalOffset: 1
                fast: true
                cached: true
                color: "#22000000"
            }

            states: [
                State {
                    name: "on"
                    when: control.checked
                    PropertyChanges { target: circle; x: oval.width - circle.width - 4 }
                },
                State {
                    name: "off"
                    when: !control.checked
                    PropertyChanges { target: circle; x: 4 }
                }
            ]

            transitions: Transition {
                reversible: true
                NumberAnimation { properties: "x"; easing.type: Easing.Linear; duration: 120; }
            }
        }
    }

    contentItem: StyledText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: !!control.text ? control.indicator.width + control.spacing : control.indicator.width
    }
}

