import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls

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
