import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Core 0.1

Action {
    id: statusMenuItem

    enum Type {
        Normal,
        Danger
    }

    property int type: StatusMenuItem.Type.Normal
    property real iconRotation: 0
}
