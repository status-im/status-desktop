import QtQuick 2.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root
    title: qsTr("Application Restart")

    contentItem: StatusBaseText {
        text: qsTr("Please restart the application to apply the changes.")
        wrapMode: Text.WordWrap
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                type: StatusBaseButton.Type.Danger
                text: qsTr("Restart")
                onClicked: root.accepted()
            }
        }
    }
}
