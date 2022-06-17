import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    StatusBaseText {
        Layout.fillWidth: true
        Layout.fillHeight: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        text: qsTr("Syncing process will be shown here")
    }
}
