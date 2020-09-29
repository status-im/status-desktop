import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.14
import "../../imports"
import "../../shared"

RadioButton {
    id: control
    property bool isHovered: false
    width: indicator.implicitWidth

    function getColor() {
        if (checked) {
            return Style.current.blue
        }
        if (hovered || isHovered) {
            return Style.current.secondaryHover
        }
        return Style.current.grey
    }

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: 0
        y: 6
        radius: 10
        color: control.getColor()

        Rectangle {
            width: 12
            height: 12
            radius: 6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: control.checked ? Style.current.white : Style.current.grey
            visible: control.checked
        }
    }
    contentItem: StyledText {
        text: control.text
        color: Style.current.textColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: !!control.text ? control.indicator.width + control.spacing : control.indicator.width
        font.pixelSize: 15
        font.family: Style.current.fontRegular.name
    }
}
