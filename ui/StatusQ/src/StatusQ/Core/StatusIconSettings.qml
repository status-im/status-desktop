import QtQuick 2.13
import StatusQ.Core 0.1

QtObject {
    id: statusIconSettings

    property string name
    property real width
    property real height
    property color color
    property color disabledColor
    property url source
    property int rotation
    property bool isLetterIdenticon
    property int letterSize
    property StatusIconBackgroundSettings background: StatusIconBackgroundSettings {}
}
