import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.controls 1.0

import SortFilterProxyModel 0.2
import utils 1.0


Control {
    id: root

    property bool joinCommunity: true // Otherwise it means join channel action
    property bool allChannelsAreHiddenBecauseNotPermitted: false
    property bool requirementsMet: false
    property bool requirementsCheckPending: false
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

    property var assetsModel
    property var collectiblesModel

    signal requestToJoinClicked
    signal invitationPendingClicked

    QtObject {
        id: d

        readonly property string communityRequirementsNotMetText: qsTr("Membership requirements not met")
        readonly property string communityRequestToJoinText: qsTr("Request to join Community")
        readonly property string communityMembershipRequestPendingText: qsTr("Membership Request Pending...")
        readonly property string channelRequirementsNotMetText: qsTr("Channel requirements not met")
        readonly property string channelMembershipRequestPendingText: qsTr("Channel Membership Request Pending...")
        readonly property string memberchipRequestRejectedText: qsTr("Membership Request Rejected")
        readonly property string allChannelsAreHiddenBecauseNotPermittedText: qsTr("Sorry, you don't hodl the necessary tokens to view or post in any of <b>%1</b> channels").arg(root.communityName)

        readonly property bool onlyPrivateNotMetPermissions: (d.visiblePermissionsModel.count === 0) && root.communityHoldingsModel.count > 0

        readonly property var visiblePermissionsModel: SortFilterProxyModel {
            sourceModel: root.communityHoldingsModel

            filters: [
                // The only permissions to be discarded are if they are private and NOT met
                FastExpressionFilter {
                    expression: d.filterPermissions(model)
                    expectedRoles: ["tokenCriteriaMet", "isPrivate"]
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

        readonly property var moderatePermissionsModel: SortFilterProxyModel {
            sourceModel: root.moderateHoldingsModel
            filters: [
                ExpressionFilter {
                    expression: d.filterPermissions(model)
                }
            ]
        }

        function filterPermissions(model) {
            return !!model && (model.tokenCriteriaMet || !model.isPrivate)
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
            introText: !d.onlyPrivateNotMetPermissions ?
                qsTr("To join <b>%1</b> you need to prove that you hold").arg(root.communityName) : 
                qsTr("Sorry, you can't join <b>%1</b> because it's a private, closed community").arg(root.communityName)
            model: d.visiblePermissionsModel
        }

        StatusBaseText {
            Layout.fillWidth: true

            visible: root.allChannelsAreHiddenBecauseNotPermitted
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: d.allChannelsAreHiddenBecauseNotPermittedText
            textFormat: Text.StyledText
        }

        CustomHoldingsListPanel {
            visible: (!root.joinCommunity && d.viewOnlyPermissionsModel.count > 0) && !root.allChannelsAreHiddenBecauseNotPermitted
            introText: root.requiresRequest ? 
                qsTr("To view the <b>#%1</b> channel you need to join <b>%2</b> and prove that you hold").arg(root.channelName).arg(root.communityName) :
                qsTr("To view the <b>#%1</b> channel you need to hold").arg(root.channelName)
            model: d.viewOnlyPermissionsModel
        }

        CustomHoldingsListPanel {
            visible: (!root.joinCommunity && d.viewAndPostPermissionsModel.count > 0) && !root.allChannelsAreHiddenBecauseNotPermitted
            introText: root.requiresRequest ? qsTr("To view and post in the <b>#%1</b> channel you need to join <b>%2</b> and prove that you hold").arg(root.channelName).arg(root.communityName) :
                                              qsTr("To view and post in the <b>#%1</b> channel you need to hold").arg(root.channelName)
            model: d.viewAndPostPermissionsModel
        }

        CustomHoldingsListPanel {
            visible: !root.joinCommunity && d.moderatePermissionsModel.count > 0
            introText: qsTr("To moderate in the <b>#%1</b> channel you need to hold").arg(root.channelName)
            model: d.moderatePermissionsModel
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            visible: !root.showOnlyPanels
                                 && !root.isJoinRequestRejected
                                 && root.requiresRequest
                                 && !d.onlyPrivateNotMetPermissions
                                 && !root.allChannelsAreHiddenBecauseNotPermitted
                        text: root.isInvitationPending ? (root.joinCommunity ? d.communityMembershipRequestPendingText : d.channelMembershipRequestPendingText)
                                                       : d.communityRequestToJoinText
                        font.pixelSize: 13
                        enabled: root.requirementsMet || (root.joinCommunity && d.visiblePermissionsModel.count === 0)

                        onClicked: root.isInvitationPending ? root.invitationPendingClicked() : root.requestToJoinClicked()
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            visible: !root.showOnlyPanels
                     && !root.requirementsCheckPending
                     && (root.isJoinRequestRejected || !root.requirementsMet)
                     && !d.onlyPrivateNotMetPermissions
                     && !root.allChannelsAreHiddenBecauseNotPermitted
            text: root.isJoinRequestRejected ? d.memberchipRequestRejectedText :
                                          (root.joinCommunity ? d.communityRequirementsNotMetText : d.channelRequirementsNotMetText)
            color: Theme.palette.dangerColor1
        }

        RequirementsCheckPendingLoader {
            visible: root.requirementsCheckPending
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
