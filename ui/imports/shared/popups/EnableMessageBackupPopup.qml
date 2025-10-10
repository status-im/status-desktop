import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups.Dialog

StatusDialog {
    id: root

    title: qsTr("Enable on-device message backup?")

    padding: 20
    width: 480
    closePolicy: Popup.NoAutoClose

    contentItem: ColumnLayout {
        spacing: Theme.padding

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("On-device backups are:<br>Automatic – every 30 minutes<br>Secure – encrypted with your profile private key<br>Private – stored only on your device")
        }
        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("Backups let you restore your 1-on-1, group, and community messages if you need to reinstall the app or switch devices. You can skip this step now and enable it anytime under: <i>Settings > On-device backup > Backup data</i>")
        }
    }

    footer: StatusDialogFooter {
        leftButtons: ObjectModel {
            StatusFlatButton {
                objectName: "backupMessageSkipStatusFlatButton"
                text: qsTr("Skip")
                onClicked: root.close()
            }
        }
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "backupMessageEnableStatusFlatButton"
                text: qsTr("Enable")
                onClicked: root.accept()
            }
        }
    }
}
