import QtQuick 2.13
import StatusQ.Core 0.1

QtObject {
    id: statusIconSettings

    property string name
    property real width
    property real height
    property color color
    property url source
    property int rotation
    property StatusIconBackgroundSettings background: StatusIconBackgroundSettings {}
}
