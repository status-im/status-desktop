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
            const link = '<a href="https://github.com/status-im/status-desktop/issues/6097">#6097 AuthorizationWorkflow</a>';
            return qsTr("This text will be replaced with %1").arg(link);
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitWidth: warningMessage.implicitWidth
        implicitHeight: warningMessage.implicitHeight
        color: Theme.palette.dangerColor3
        radius: 8

        StatusBaseText {
            id: warningMessage
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            topPadding: 8
            bottomPadding: 8
            leftPadding: 16
            rightPadding: 16
            color: Theme.palette.dangerColor1
            text: qsTr("The next screen contains a QR and sync code.<br><b>Anyone</b> who sees it can use it to access to your funds.")
        }
    }
}
