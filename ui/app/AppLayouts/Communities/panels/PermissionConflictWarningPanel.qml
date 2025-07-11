import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils

Control {
    id: root

    property string holdings
    property string permissions
    property string channels

    spacing: 8

    QtObject {
        id: d

        property int iconSize: 20
    }

    contentItem: ColumnLayout {
        spacing: 4

        RowLayout {
            spacing: root.spacing

            StatusIcon {
                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize
                Layout.alignment: Qt.AlignTop
                color: Theme.palette.dangerColor1
                icon: "warning"
            }
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: Theme.primaryTextFontSize
                color: Theme.palette.dangerColor1
                font.bold: true
                text: qsTr("Conflicts with existing permission:")
            }
        }

        StatusBaseText {
            Layout.leftMargin: root.spacing + d.iconSize
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Theme.primaryTextFontSize
            font.bold: true
            text: qsTr("\"Anyone who holds %1 can %2 in %3\"").arg(root.holdings).arg(root.permissions).arg(root.channels)
        }

        StatusBaseText {
            Layout.leftMargin: root.spacing + d.iconSize
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("Edit permissions to resolve a conflict.")
        }
    }
}
