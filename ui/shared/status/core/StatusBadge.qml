import QtQuick 2.13
import "../../../imports"
import "../../"

Rectangle {
    id: statusBadge

    property int value

    implicitHeight: statusBadge.value > 0 ? 18 + statusBadge.border.width : 10 + statusBadge.border.width
    implicitWidth: {
        if (statusBadge.value > 99) {
            return 28 + statusBadge.border.width
        }
        if (statusBadge.value > 9) {
            return 26 + statusBadge.border.width
        }
        if (statusBadge.value > 0) {
            return 18 + statusBadge.border.width
        }
        return 10 + statusBadge.border.width
    }
    radius: height / 2
    color: Style.current.blue
    StyledText {
        id: value
        visible: statusBadge.value > 0
        font.pixelSize: statusBadge.value > 99 ? 10 : 12
        color: Style.current.white
        anchors.centerIn: parent
        text: {
            if (statusBadge.value > 99) {
                return "99+";
            }
            return statusBadge.value;
        }
    }
}
