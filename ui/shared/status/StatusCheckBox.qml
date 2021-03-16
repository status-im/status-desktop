import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

CheckBox {
    id: control

    indicator: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        color: (control.down || control.checked) ? Style.current.primary : Style.current.inputBackground

        SVGImage {
            source: "../img/checkmark.svg"
            width: 16
            height: 16
            anchors.centerIn: parent
            visible: control.down || control.checked
        }
    }

    contentItem: StyledText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        width: parent.width
        leftPadding: !!control.text ? control.indicator.width + control.spacing : control.indicator.width
    }
}

