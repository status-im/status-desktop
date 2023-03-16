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

    QtObject {
        id: d

        readonly property int maxWidth: 640
        readonly property int minWidth: 300
        readonly property int maxHeight: 640

        function getHorizontalPaddings() {
            return root.leftPadding + root.rightPadding
        }

        function getVerticalPaddings() {
            return  root.topPadding + root.bottomPadding
        }

        function getMaxMinWidth() {
            return Math.max(introText.implicitWidth, d.minWidth - d.getHorizontalPaddings())
        }
    }

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

    implicitWidth: Math.min(d.getMaxMinWidth(), d.maxWidth - d.getHorizontalPaddings())
    implicitHeight: Math.min(columnContent.height + footer.height + header.height + d.getVerticalPaddings(), d.maxHeight)

    StatusScrollView {
        anchors.fill: parent
        contentHeight: columnContent.height
        contentWidth: columnContent.width
        padding: 0

        ColumnLayout {
            id: columnContent

            spacing: 24
            width: Math.max(root.width - d.getHorizontalPaddings(), d.minWidth - d.getHorizontalPaddings())

            StatusRoundedImage {
                id: roundImage

                Layout.alignment: Qt.AlignCenter
                Layout.preferredHeight: 64
                Layout.preferredWidth: Layout.preferredHeight
                visible: image.status == Image.Loading || image.status == Image.Ready
                image.source: root.imageSrc
            }

            StatusBaseText {
                id: introText

                Layout.fillWidth: true
                text: root.introMessage !== "" ? root.introMessage : qsTr("Community <b>%1</b> has no intro message...").arg(root.name)
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
            }

            StatusCheckBox {
                id: checkBox

                Layout.alignment: Qt.AlignCenter
                visible: !root.isInvitationPending
                text: qsTr("I agree with the above")
            }
        }
    }
}
