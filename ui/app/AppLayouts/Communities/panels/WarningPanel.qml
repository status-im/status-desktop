import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

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
