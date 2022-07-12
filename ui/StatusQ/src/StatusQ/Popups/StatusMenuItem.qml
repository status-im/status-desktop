import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Core 0.1

Action {
    id: statusMenuItem

    enum Type {
        Normal,
        Danger
    }
    icon.color: "transparent"
    property int type: StatusMenuItem.Type.Normal
    property real iconRotation: 0
    property StatusImageSettings image: StatusImageSettings {
        height: 16
        width: 16
        isIdenticon: false
    }
    property StatusIconSettings iconSettings: StatusIconSettings {
        isLetterIdenticon: false
        background: StatusIconBackgroundSettings {}
        color: "transparent"
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}
}
