import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1

ColumnLayout {
    id: root

    property bool joinCommunity: true // Otherwise it means join channel action

    property string name
    property string channelName

    property bool isInvitationPending: false
    property bool isJoinRequestRejected: false
    property bool requiresRequest: false
    property alias loginType: overlayPanel.loginType

    property bool requirementsMet: true

    property var communityHoldingsModel
    property var viewOnlyHoldingsModel
    property var viewAndPostHoldingsModel
    property var moderateHoldingsModel
    property var assetsModel
    property var collectiblesModel

    property string chatDateTimeText
    property string listUsersText
    property var messagesModel

    signal revealAddressClicked
    signal invitationPendingClicked

    spacing: 0

    // Blur background:
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(
                                    centralPanelData.implicitHeight,
                                    parent.height - overlayPanel.implicitHeight)

        ColumnLayout {
            id: centralPanelData
            width: parent.width
            layer.enabled: true
            layer.effect: fastBlur

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 30
                Layout.bottomMargin: 30
                text: root.chatDateTimeText
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                StatusBaseText {
                    text: root.listUsersText
                    font.pixelSize: 13
                }

                StatusBaseText {
                    text: qsTr("joined the channel")
                    font.pixelSize: 13
                    color: Theme.palette.baseColor1
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height + spacing
                Layout.topMargin: 16
                spacing: 16
                model: root.messagesModel
                delegate: StatusMessage {
                    width: ListView.view.width
                    timestamp: model.timestamp
                    enabled: false
                    messageDetails: StatusMessageDetails {
                        messageText: model.message
                        contentType: model.contentType
                        sender.displayName: model.senderDisplayName
                        sender.isContact: model.isContact
                        sender.trustIndicator: model.trustIndicator
                        sender.profileImage: StatusProfileImageSettings {
                            width: 40
                            height: 40
                            name: model.profileImage || ""
                            colorId: model.colorId
                        }
                    }
                }
            }
        }
    }

    // Permissions base information content:
    Rectangle {
        id: panelBase

        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        gradient: Gradient {
            GradientStop {
                position: 0.000
                color: "transparent"
            }
            GradientStop {
                position: 0.180
                color: panelBase.color
            }
        }

        StatusScrollView {
            anchors.fill: parent
            padding: 0

            Item {
                implicitHeight: Math.max(overlayPanel.implicitHeight,
                                         panelBase.height)
                implicitWidth: Math.max(overlayPanel.implicitWidth,
                                        panelBase.width)

                JoinPermissionsOverlayPanel {
                    id: overlayPanel

                    anchors.centerIn: parent

                    topPadding: 2 * bottomPadding
                    joinCommunity: root.joinCommunity
                    requirementsMet: root.requirementsMet
                    isInvitationPending: root.isInvitationPending
                    isJoinRequestRejected: root.isJoinRequestRejected
                    requiresRequest: root.requiresRequest
                    communityName: root.name
                    communityHoldingsModel: root.communityHoldingsModel
                    channelName: root.channelName

                    viewOnlyHoldingsModel: root.viewOnlyHoldingsModel
                    viewAndPostHoldingsModel: root.viewAndPostHoldingsModel
                    moderateHoldingsModel: root.moderateHoldingsModel
                    assetsModel: root.assetsModel
                    collectiblesModel: root.collectiblesModel

                    onRevealAddressClicked: root.revealAddressClicked()
                    onInvitationPendingClicked: root.invitationPendingClicked()
                }
            }
        }
    }

    Component {
        id: fastBlur

        FastBlur {
            radius: 32
            transparentBorder: true
        }
    }
}
