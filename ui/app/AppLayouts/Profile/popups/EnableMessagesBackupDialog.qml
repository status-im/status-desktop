import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups.Dialog

StatusDialog {
    id: root

    title: qsTr("Enable Local Messages Backup")

    padding: Theme.padding
    width: 500

    signal enableRequested()

    contentItem: ColumnLayout {
        spacing: Theme.padding

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.secondaryAdditionalTextSize
            text: qsTr("Enabling local message backup will store all your messages on your device in an encrypted backup file.")
        }
        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.secondaryAdditionalTextSize
            text: qsTr("Make sure to keep this file secure.")
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            RowLayout {
                Layout.rightMargin: Theme.padding
                spacing: Theme.bigPadding
                StatusFlatButton {
                    textColor: Theme.palette.directColor1
                    text: qsTr("Cancel")
                    onClicked: root.close()
                }
                StatusButton {
                    text: qsTr("Enable")
                    onClicked: root.enableRequested()
                }
            }
        }
    }
}