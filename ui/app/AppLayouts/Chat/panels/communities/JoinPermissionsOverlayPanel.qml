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
import utils 1.0


Control {
    id: root

    property bool joinCommunity: true // Otherwise it means join channel action
    property bool requirementsMet: false
    property bool requiresRequest: false
    property bool isInvitationPending: false
    property bool isJoinRequestRejected: false
    property string communityName
    property var communityHoldingsModel
    property string channelName
    property var viewOnlyHoldingsModel
    property var viewAndPostHoldingsModel
    property var moderateHoldingsModel
    property bool showOnlyPanels: false
    property int loginType: Constants.LoginType.Password

    property var assetsModel
    property var collectiblesModel

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

        function getRevealAddressIcon() {
            if(root.loginType == Constants.LoginType.Password) return "password"
            return root.loginType == Constants.LoginType.Biometrics ? "touch-id" : "keycard"
        }

        function filterPermissions(model) {
            return !!model && (model.tokenCriteriaMet || !model.isPrivate)
        }

        readonly property var communityPermissionsModel: SortFilterProxyModel {
            sourceModel: root.communityHoldingsModel
            filters: [
                ExpressionFilter {
                    expression: d.filterPermissions(model)
                }
            ]
        }

        readonly property var viewOnlyPermissionsModel: SortFilterProxyModel {
            sourceModel: root.viewOnlyHoldingsModel
            filters: [
                ExpressionFilter {
                    expression: d.filterPermissions(model)
                }
            ]
        }

        readonly property var viewAndPostPermissionsModel: SortFilterProxyModel {
            sourceModel: root.viewAndPostHoldingsModel
            filters: [
                ExpressionFilter {
                    expression: d.filterPermissions(model)
                }
            ]
        }

    }

    padding: 35 // default by design
    spacing: 32 // default by design
    contentItem: ColumnLayout {
        id: column

        spacing: root.spacing

        component CustomHoldingsListPanel: HoldingsListPanel {
            Layout.fillWidth: true

            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel

            spacing: root.spacing
        }

        CustomHoldingsListPanel {
            id: communityRequirements

            visible: root.joinCommunity
            introText: d.communityPermissionsModel.count > 0 ? 
                qsTr("To join <b>%1</b> you need to prove that you hold").arg(root.communityName) : 
                qsTr("Sorry, you can't join <b>%1</b> because it's a private, closed community").arg(root.communityName)
            model: d.communityPermissionsModel
        }

        CustomHoldingsListPanel {
            visible: !root.joinCommunity && d.viewOnlyPermissionsModel.count > 0
            introText: root.requiresRequest ? 
                qsTr("To view the #<b>%1</b> channel you need to join <b>%2</b> and prove that you hold").arg(root.channelName).arg(root.communityName) :
                qsTr("To view the #<b>%1</b> channel you need to hold").arg(root.channelName)
            model: d.viewOnlyPermissionsModel
        }

        CustomHoldingsListPanel {
            visible: !root.joinCommunity && d.viewAndPostPermissionsModel.count > 0
            introText: root.requiresRequest ? 
                qsTr("To view and post in the #<b>%1</b> channel you need to join <b>%2</b> and prove that you hold").arg(root.channelName).arg(root.communityName) :
                qsTr("To view and post in the #<b>%1</b> channel you need to hold").arg(root.channelName)
            model: d.viewAndPostPermissionsModel
        }

        HoldingsListPanel {
            Layout.fillWidth: true
            spacing: root.spacing
            visible: !root.joinCommunity && !!d.moderateHoldings
            introText: qsTr("To moderate in the <b>%1</b> channel you need to hold").arg(root.channelName)
            model: d.moderateHoldingsModel
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            visible: !root.showOnlyPanels && !root.isJoinRequestRejected && root.requiresRequest
            text: root.isInvitationPending ? d.getInvitationPendingText() : d.getRevealAddressText()
            icon.name: root.isInvitationPending ? "" : d.getRevealAddressIcon()
            font.pixelSize: 13
            enabled: root.requirementsMet || d.communityPermissionsModel.count == 0
            onClicked: root.isInvitationPending ? root.invitationPendingClicked() : root.revealAddressClicked()
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            visible: !root.showOnlyPanels && (root.isJoinRequestRejected || !root.requirementsMet)
            text: root.isJoinRequestRejected ? d.memberchipRequestRejectedText :
                                          (root.joinCommunity ? d.communityRequirementsNotMetText : d.channelRequirementsNotMetText)
            color: Theme.palette.dangerColor1
        }
    }
}

