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
        implicitWidth: 20 * scaleAction.factor
        implicitHeight: 20 * scaleAction.factor
        x: 0
        y: 6
        radius: 10
        color: control.getColor()

        Rectangle {
            width: 12 * scaleAction.factor
            height: 12 * scaleAction.factor
            radius: width / 2
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
        font.pixelSize: 15 * scaleAction.factor
        font.family: Style.current.fontRegular.name
    }
}
