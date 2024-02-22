import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1

import utils 1.0


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

    width: 400

    title: root.mode === KickBanPopup.Mode.Kick
           ? qsTr("Kick %1").arg(root.username)
           : qsTr("Ban %1").arg(root.username)

    contentItem: ColumnLayout {
        anchors.centerIn: parent

        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true

            font.pixelSize: Style.current.primaryTextFontSize
            wrapMode: Text.Wrap

            text: root.mode === KickBanPopup.Mode.Kick
                  ? qsTr("Are you sure you want to kick <b>%1</b> from %2?")
                    .arg(root.username).arg(root.communityName)
                  : qsTr("Are you sure you want to ban <b>%1</b> from %2? This means that they will be kicked from this community and banned from re-joining.")
            .arg(root.username).arg(root.communityName)
        }

            RowLayout {
                visible: root.mode === KickBanPopup.Mode.Ban

                StatusBaseText {
                    Layout.fillWidth: true

                    text: qsTr("Delete all messages posted by the user")
                    font.pixelSize: Style.current.primaryTextFontSize
                }

                StatusSwitch {
                    id: deleteAllMessagesSwitch

                    checked: false
                }
            }
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
