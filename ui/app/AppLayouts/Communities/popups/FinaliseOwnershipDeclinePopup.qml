import QtQuick
import QtQuick.Controls
import QtQml.Models

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Popups.Dialog
import StatusQ.Core.Theme

import utils

StatusDialog {
    id: root

    // Community related props:
    required property string communityName
    required property string communityId

    signal cancelClicked
    signal declineClicked

    width: 480 // by design
    padding: Theme.padding
    title: qsTr("Are you sure you don’t want to be the owner?")
    contentItem: StatusBaseText {
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("If you don’t want to be the owner of the %1 Community it is important that you let the previous owner know so they can organise another owner to take over. You will have to send the Owner token back to them or on to the next designated owner.").arg(root.communityName)
        lineHeight: 1.2
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")

                onClicked: close()
            }

            StatusButton {
                text: qsTr("I don't want to be the owner")
                type: StatusBaseButton.Type.Danger

                onClicked: {
                    root.declineClicked()
                    close()
                }
            }
        }
    }
}
