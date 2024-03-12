import QtQuick 2.15
import QtQuick.Controls 2.15

import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property alias body: bodyItem.text
    property alias acceptButtonText: acceptButton.text
    property alias rejectButtonText: rejectButton.text

    implicitWidth: 480
    closePolicy: Popup.NoAutoClose
    
    footer: StatusDialogFooter {
        spacing: 16
        rightButtons: ObjectModel {
            StatusButton {
                id: rejectButton
                type: StatusButton.Danger
                onClicked: {
                    root.reject();
                }
            }
            StatusButton {
                id: acceptButton
                onClicked: {
                    root.accept();
                }
            }
        }
    }

    StatusBaseText {
        id: bodyItem
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }
}
