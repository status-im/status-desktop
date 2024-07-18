import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

RowLayout {
    id: root

    property string networkThatIsNotActive
    signal enableNetwork

    spacing: 6

    WarningPanel {
        id: wantedNetworkNotActive
        Layout.fillWidth: true
        text: qsTr("The owner token is minted on a network that isn't selected. Click here to enable it:")
    }

    StatusButton {
        text: qsTr("Enable %1").arg(root.networkThatIsNotActive)
        Layout.alignment: Qt.AlignVCenter
        onClicked: root.enableNetwork()
    }
}
