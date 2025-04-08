import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    width: 440
    padding: Theme.smallPadding*2
    topPadding: Theme.xlPadding
    bottomPadding: Theme.xlPadding

    closePolicy: Popup.NoAutoClose

    title: qsTr("Enable full message history")

    contentItem: ColumnLayout {
        spacing: Theme.xlPadding

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("Enabling the Community History Service ensures every member can view the complete message history for all channels they have permission to view. Without this feature, message history will be limited to the last 30 days. Your computer, which is the control node for the community, must remain online for this to work.")
        }

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Theme.palette.directColor5
            text: qsTr("This service operates using the Archive Protocol, which will be automatically enabled.")
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                objectName: "readMoreStatusFlatButton"
                icon.name: "external-link"
                text: qsTr("Read more")
                onClicked: root.accept()
            }

            StatusButton {
                objectName: "gotItStatusFlatButton"
                text: qsTr("Got it")
                onClicked: root.close()
            }
        }
    }
}
