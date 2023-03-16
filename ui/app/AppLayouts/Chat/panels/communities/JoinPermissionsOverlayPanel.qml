import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Chat.helpers 1.0
import AppLayouts.Chat.controls.community 1.0

import SortFilterProxyModel 0.2


Control {
    id: root

    property bool joinCommunity: true // Otherwise it means join channel action
    property bool requirementsMet: false
    property bool requiresRequest: false
    property bool isInvitationPending: false
    property bool isJoinRequestRejected: false
    property string communityName
    property var communityHoldings
    property string channelName
    property var viewOnlyHoldings
    property var viewAndPostHoldings
    property var moderateHoldings

    signal revealAddressClicked
    signal invitationPendingClicked

    QtObject {
        id: d

        readonly property string communityRequirementsNotMetText: qsTr("Membership requirements not met")
        readonly property string communityRevealAddressText: qsTr("Reveal your address to join")
        readonly property string communityRevealAddressWithRequestText: qsTr("Reveal your address and request to join")
        readonly property string communityMembershipRequestPendingText: qsTr("Membership Request Pending...")
        readonly property string channelRequirementsNotMetText: qsTr("Channel requirements not met")
        readonly property string channelRevealAddressText: qsTr("Reveal your address to enter")
        readonly property string channelMembershipRequestPendingText: qsTr("Channel Membership Request Pending...")
        readonly property string memberchipRequestRejectedText: qsTr("Membership Request Rejected")

        function holdingsTextFormat(name, amount) {
            return CommunityPermissionsHelpers.setHoldingsTextFormat(HoldingTypes.Type.Asset, name, amount)
        }

        function getInvitationPendingText() {
            return root.joinCommunity ? d.communityMembershipRequestPendingText : d.channelMembershipRequestPendingText
        }

        function getRevealAddressText() {
            return root.joinCommunity ? (root.requiresRequest ? d.communityRevealAddressWithRequestText : d.communityRevealAddressText) : d.channelRevealAddressText
        }
    }

    padding: 35 // default by design
    spacing: 32 // default by design
    contentItem: ColumnLayout {
        id: column
        spacing: root.spacing

        HoldingsListPanel {
            Layout.fillWidth: true
            spacing: root.spacing
            visible: root.joinCommunity && root.communityHoldings
            introText: qsTr("To join <b>%1</b> you need to prove that you hold").arg(root.communityName)
            model: root.communityHoldings
        }

        HoldingsListPanel {
            Layout.fillWidth: true
            spacing: root.spacing
            visible: !root.joinCommunity && !!root.viewOnlyHoldings
            introText: qsTr("To only view the <b>%1</b> channel you need to hold").arg(root.channelName)
            model: root.viewOnlyHoldings
        }

        HoldingsListPanel {
            Layout.fillWidth: true
            spacing: root.spacing
            visible: !root.joinCommunity && !!root.viewAndPostHoldings
            introText: qsTr("To view and post in the <b>%1</b> channel you need to hold").arg(root.channelName)
            model: root.viewAndPostHoldings
        }

        HoldingsListPanel {
            Layout.fillWidth: true
            spacing: root.spacing
            visible: !root.joinCommunity && !!root.moderateHoldings
            introText: qsTr("To moderate in the <b>%1</b> channel you need to hold").arg(root.channelName)
            model: root.moderateHoldings
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            visible: !root.isJoinRequestRejected
            text: root.isInvitationPending ? d.getInvitationPendingText() : d.getRevealAddressText()
            font.pixelSize: 13
            enabled: root.requirementsMet
            onClicked: root.isInvitationPending ? root.invitationPendingClicked() : root.revealAddressClicked()
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            visible: root.isJoinRequestRejected || !root.requirementsMet
            text: root.isJoinRequestRejected ? d.memberchipRequestRejectedText :
                                          (root.joinCommunity ? d.communityRequirementsNotMetText : d.channelRequirementsNotMetText)
            color: Theme.palette.dangerColor1
        }
    }
}

