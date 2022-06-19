import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ColumnLayout {
    id: root

    StatusBaseText {
        Layout.fillWidth: true
        Layout.fillHeight: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        linkColor: Theme.palette.primaryColor1
        onLinkActivated: Global.openLink(link)

        text: {
            const link = '<a href="https://github.com/status-im/status-desktop/pull/5756">#5756 Scan QR code</a>';
            return qsTr("This text will be replaced with %1").arg(link);
        }
    }
}
