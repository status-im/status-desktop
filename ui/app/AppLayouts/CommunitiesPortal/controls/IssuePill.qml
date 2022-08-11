import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root

    enum Type {
        Warning,
        Error
    }
    property int type: IssuePill.Type.Warning

    property int count

    horizontalPadding: 8
    verticalPadding: 4

    QtObject {
        id: d
        readonly property color baseColor: root.type === IssuePill.Type.Warning ? Theme.palette.pinColor1
                                                                                : Theme.palette.dangerColor1
    }

    background: Rectangle {
        radius: 100
        color: Theme.palette.alphaColor(d.baseColor, 0.03)
        border.width: 1
        border.color: Theme.palette.alphaColor(d.baseColor, 0.3)
    }

    contentItem: RowLayout {
        spacing: 4
        StatusIcon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            icon: "warning"
            color: d.baseColor
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Qt.AlignVCenter
            text: root.type === IssuePill.Type.Warning ? qsTr("%n warning(s)", "", root.count)
                                                       : qsTr("%n error(s)", "", root.count)
            color: d.baseColor
            font.pixelSize: 12
        }
    }
}
