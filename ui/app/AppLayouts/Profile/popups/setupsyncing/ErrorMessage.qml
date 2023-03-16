import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property string primaryText
    property string secondaryText

    spacing: 12

    StatusBaseText {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height / 2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        text: root.primaryText
        font.pixelSize: 17
        color: Theme.palette.dangerColor1
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 60
        Layout.rightMargin: 60
        Layout.preferredWidth: 360
        Layout.preferredHeight: parent.height / 2
        Layout.minimumHeight: detailsView.implicitHeight

        ErrorDetails {
            id: detailsView

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            title: qsTr("Failed to start pairing server")
            details: root.secondaryText
        }
    }
}
