import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import utils
import shared.controls.chat

StatusDialog {
    id: root

    width: 480
    padding: Theme.smallPadding*2
    topPadding: Theme.xlPadding

    closePolicy: Popup.NoAutoClose

    title: qsTr("Do you wish to enable message backup?")

    contentItem: ColumnLayout {
        spacing: Theme.xlPadding

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("You can now enable message backup to keep your messages on your device.")
        }

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("This will allow you to restore your messages if you reinstall the app or switch devices.")
        }

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("Just remember to keep your backup file safe and secure!")
        }

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("You can change your mind in the Syncing settings later.")
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                objectName: "backupMessageSkipStatusFlatButton"
                text: qsTr("Skip")
                onClicked: root.close()
            }
            StatusButton {
                objectName: "backupMessageEnableStatusFlatButton"
                icon.name: "settings"
                text: qsTr("Enable")
                onClicked: root.accept()
            }
        }
    }
}
