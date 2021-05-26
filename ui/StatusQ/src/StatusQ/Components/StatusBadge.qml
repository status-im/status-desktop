import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

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
    color: Theme.palette.primaryColor1

    StatusBaseText {
        id: value
        visible: statusBadge.value > 0
        font.pixelSize: statusBadge.value > 99 ? 10 : 12
        font.weight: Font.Medium
        color: Theme.palette.statusBadge.foregroundColor
        anchors.centerIn: parent
        text: {
            if (statusBadge.value > 99) {
                return "99+";
            }
            return statusBadge.value;
        }
    }
}
