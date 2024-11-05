import QtQuick 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: popup

    title: qsTr("Send")

    padding: 0
    background: StatusDialogBackground {
        implicitHeight: 846
        implicitWidth: 556
        color: Theme.palette.baseColor3
    }
}
