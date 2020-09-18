import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Switch {
    id: control

    indicator: Rectangle {
        implicitWidth: 52
        implicitHeight: 28
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 14
        color: control.checked ? Style.current.blue : Style.current.grey

        Rectangle {
            x: control.checked ? parent.width - width-4 : 4
            y: 4
            width: 20
            height: 20
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
        }
    }

    contentItem: StyledText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: !!control.text ? control.indicator.width + control.spacing : control.indicator.width
    }
}

