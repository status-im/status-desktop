import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDialog {
    id: root

    // Community related props:
    required property string communityName
    required property string communityId

    signal cancelClicked
    signal declineClicked

    width: 480 // by design
    padding: Style.current.padding
    title: qsTr("Are you sure you don’t want to be the owner?")
    contentItem: StatusBaseText {
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("If you don’t want to be the owner of the %1 Community it is important that you let the previous owner know so they can organise another owner to take over. You will have to send the Owner token back to them or on to the next designated owner.").arg(root.communityName)
        lineHeight: 1.2
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
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
