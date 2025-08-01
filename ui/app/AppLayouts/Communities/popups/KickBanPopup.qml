import QtQuick
import QtQml.Models
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog
import StatusQ.Components

import utils


StatusDialog {
    id: root

    property string username: ""
    property string communityName: ""
    property int mode: KickBanPopup.Mode.Kick

    signal banUserClicked(bool deleteAllMessages)
    signal kickUserClicked()

    enum Mode {
        Kick, Ban
    }

    width: 480

    title: root.mode === KickBanPopup.Mode.Kick
           ? qsTr("Kick %1").arg(root.username)
           : qsTr("Ban %1").arg(root.username)

    contentItem: ColumnLayout {
        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true

            wrapMode: Text.Wrap

            text: root.mode === KickBanPopup.Mode.Kick
                  ? qsTr("Are you sure you want to kick <b>%1</b> from %2?").arg(root.username).arg(root.communityName)
                  : qsTr("Are you sure you want to ban <b>%1</b> from %2? This means that they will be kicked from this community and banned from re-joining.").arg(root.username).arg(root.communityName)
        }

        StatusSwitch {
            Layout.fillWidth: true
            id: deleteAllMessagesSwitch
            visible: root.mode === KickBanPopup.Mode.Ban
            leftSide: false
            text: qsTr("Delete all messages posted by the user")
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")

                onClicked: root.close()
            }
            StatusButton {
                objectName: root.mode === KickBanPopup.Mode.Kick
                            ? "CommunityMembers_KickModal_KickButton"
                            : "CommunityMembers_BanModal_BanButton"

                text: root.mode === KickBanPopup.Mode.Kick ? qsTr("Kick %1").arg(root.username)
                                                           : qsTr("Ban %1").arg(root.username)
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.mode === KickBanPopup.Mode.Kick ? root.kickUserClicked()
                                                         : root.banUserClicked(deleteAllMessagesSwitch.checked)
                    root.close()
                }
            }
        }
    }

    onClosed: deleteAllMessagesSwitch.checked = false
}
