import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    signal connectionStringFound(connectionString: string)

    implicitWidth: 330
    implicitHeight: 330

    radius: 16
    color: Theme.palette.baseColor4


    StatusBaseText {
        id: text
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 15
        color: Theme.palette.dangerColor1
        text: qsTr("QR code scanning is not available yet")
    }
}
