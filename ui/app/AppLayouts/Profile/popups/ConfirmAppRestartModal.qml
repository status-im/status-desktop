import QtQuick
import QtQml.Models

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Popups.Dialog

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
