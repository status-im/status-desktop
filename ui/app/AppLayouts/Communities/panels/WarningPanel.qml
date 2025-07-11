import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils

Control {
    id: root

    property alias text: warningText.text

    spacing: Theme.halfPadding

    QtObject {
        id: d

        readonly property int iconSize: 20
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusIcon {
            Layout.preferredWidth: d.iconSize
            Layout.preferredHeight: d.iconSize
            Layout.alignment: Qt.AlignTop

            color: Theme.palette.dangerColor1
            icon: "warning"
        }

        StatusBaseText {
            id: warningText

            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.dangerColor1
        }
    }
}
