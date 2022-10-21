import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.1
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property string name
    property string introMessage
    property int accessType
    property url imageSrc
    property bool isInvitationPending: false

    signal joined
    signal cancelMembershipRequest

    title: qsTr("Welcome to %1").arg(name)

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: root.isInvitationPending ? qsTr("Cancel Membership Request")
                                               : (root.accessType === Constants.communityChatOnRequestAccess
                                                  ? qsTr("Request to join %1").arg(root.name)
                                                  : qsTr("Join %1").arg(root.name) )
                type: root.isInvitationPending ? StatusBaseButton.Type.Danger
                                               : StatusBaseButton.Type.Normal
                enabled: checkBox.checked || root.isInvitationPending

                onClicked: {
                    if (root.isInvitationPending) {
                        root.cancelMembershipRequest()
                    } else {
                       root.joined()
                    }

                    root.close()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        spacing: 24

        StatusRoundedImage {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: 64
            Layout.preferredWidth: 64

            visible: image.status == Image.Loading || image.status == Image.Ready
            image.source: root.imageSrc
        }

        StatusScrollView {
            Layout.minimumWidth: 300
            Layout.preferredWidth: contentWidth
            Layout.fillHeight: true

            StatusBaseText {
                id: messageContent

                width: Math.min(implicitWidth, 640)

                text: root.introMessage !== "" ? root.introMessage : qsTr("Community <b>%1</b> has no intro message...").arg(root.name)
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
            }
        }

        StatusCheckBox {
            id: checkBox
            Layout.alignment: Qt.AlignCenter
            visible: !root.isInvitationPending
            text: qsTr("I agree with the above")
        }
    }
}
