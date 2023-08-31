import QtQuick 2.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0


StatusDialog {
    id: root

    property string username: ""
    property string communityName: ""
    property int mode: KickBanPopup.Mode.Kick

    enum Mode {
        Kick, Ban
    }

    width: 400

    title: root.mode === KickBanPopup.Mode.Kick
           ? qsTr("Kick %1").arg(root.username)
           : qsTr("Ban %1").arg(root.username)

    contentItem: StatusBaseText {
        anchors.centerIn: parent
        font.pixelSize: Style.current.primaryTextFontSize
        wrapMode: Text.Wrap

        text: root.mode === KickBanPopup.Mode.Kick
              ? qsTr("Are you sure you kick <b>%1</b> from %2?")
                .arg(root.username).arg(root.communityName)
              : qsTr("Are you sure you ban <b>%1</b> from %2?")
                .arg(root.username).arg(root.communityName)
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")

                onClicked: root.close()
            }
            StatusButton {
                id: banButton

                objectName: root.mode === KickBanPopup.Mode.Kick
                            ? "CommunityMembers_KickModal_KickButton"
                            : "CommunityMembers_BanModal_BanButton"

                text: root.mode === KickBanPopup.Mode.Kick ? qsTr("Kick")
                                                           : qsTr("Ban")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.accept()
                    root.close()
                }
            }
        }
    }
}
