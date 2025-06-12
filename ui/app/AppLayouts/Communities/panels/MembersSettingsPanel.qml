import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import shared.stores 1.0 as SharedStores
import utils 1.0

import AppLayouts.Chat.stores 1.0
import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.popups 1.0

import QtModelsToolkit 1.0

SettingsPage {
    id: root

    property RootStore rootStore

    property var membersModel
    property var bannedMembersModel
    property var pendingMembersModel
    property var declinedMembersModel
    property string communityName

    property int memberRole
    property bool editable: true

    signal kickUserClicked(string id)
    signal banUserClicked(string id, bool deleteAllMessages)
    signal unbanUserClicked(string id)
    signal acceptRequestToJoin(string id)
    signal declineRequestToJoin(string id)
    signal viewMemberMessagesClicked(string pubKey, string displayName)
    signal inviteNewPeopleClicked()

    function goTo(tab: int) {
        if(root.contentItem) {
            root.contentItem.goTo(tab)
        }
    }

    title: qsTr("Members")

    buttons: [
        StatusButton {
            text: qsTr("Invite people")
            onClicked: root.inviteNewPeopleClicked()
        }
    ]

    contentItem: ColumnLayout {

        function goTo(tab: int) {
            let tabButton = membersTabBar.currentItem
            switch (tab) {
            case Constants.CommunityMembershipSubSections.Members:
                tabButton = allMembersBtn
                break
            case Constants.CommunityMembershipSubSections.MembershipRequests:
                tabButton = pendingRequestsBtn
                break
            case Constants.CommunityMembershipSubSections.RejectedMembers:
                tabButton = declinedRequestsBtn
                break
            case Constants.CommunityMembershipSubSections.BannedMembers:
                tabButton = bannedBtn
                break
            }
            
            if (tabButton.enabled)
                membersTabBar.currentIndex = tabButton.TabBar.index
        }
        
        spacing: Theme.padding

        StatusTabBar {
            id: membersTabBar
            Layout.preferredWidth: root.preferredContentWidth

            StatusTabButton {
                readonly property int subSection: MembersTabPanel.TabType.AllMembers

                id: allMembersBtn
                objectName: "allMembersButton"
                width: implicitWidth
                text: qsTr("All Members")
            }

            StatusTabButton {
                readonly property int subSection: MembersTabPanel.TabType.PendingRequests

                id: pendingRequestsBtn
                objectName: "pendingRequestsButton"
                width: implicitWidth
                text: qsTr("Pending Requests")
                enabled: pendingMembersModel.ModelCount.count > 0
            }

            StatusTabButton {
                readonly property int subSection: MembersTabPanel.TabType.DeclinedRequests

                id: declinedRequestsBtn
                objectName: "declinedRequestsButton"
                width: implicitWidth
                text: qsTr("Rejected")
                enabled: declinedMembersModel.ModelCount.count > 0
            }

            StatusTabButton {
                readonly property int subSection: MembersTabPanel.TabType.BannedMembers

                id: bannedBtn
                objectName: "bannedButton"
                width: implicitWidth
                enabled: bannedMembersModel.ModelCount.count > 0
                text: qsTr("Banned")
            }
        }

        SearchBox {
            id: memberSearch
            Layout.preferredWidth: root.preferredContentWidth
            placeholderText: qsTr("Search by name or chat key")
            enabled: membersTabBar.currentItem.enabled
        }

        MembersTabPanel {
            Layout.preferredWidth: root.preferredContentWidth
            Layout.fillHeight: true

            panelType: membersTabBar.currentItem.subSection
            model: {
                switch (panelType) {
                case MembersTabPanel.TabType.PendingRequests:
                    return root.pendingMembersModel
                case MembersTabPanel.TabType.DeclinedRequests:
                    return root.declinedMembersModel
                case MembersTabPanel.TabType.BannedMembers:
                    return root.bannedMembersModel
                case MembersTabPanel.TabType.AllMembers:
                default:
                    return root.membersModel
                }
            }

            searchString: memberSearch.text
            rootStore: root.rootStore
            memberRole: root.memberRole

            onKickUserClicked: {
                kickBanPopup.mode = KickBanPopup.Mode.Kick
                kickBanPopup.username = name
                kickBanPopup.userId = id
                kickBanPopup.open()
            }
            onBanUserClicked: {
                kickBanPopup.mode = KickBanPopup.Mode.Ban
                kickBanPopup.username = name
                kickBanPopup.userId = id
                kickBanPopup.open()
            }
            onUnbanUserClicked: root.unbanUserClicked(id)
            onAcceptRequestToJoin: root.acceptRequestToJoin(id)
            onDeclineRequestToJoin: root.declineRequestToJoin(id)
            onViewMemberMessagesClicked: root.viewMemberMessagesClicked(pubKey, displayName)
        }
    }

    KickBanPopup {
        id: kickBanPopup

        property string userId

        communityName: root.communityName

        onBanUserClicked: root.banUserClicked(userId, deleteAllMessages)
        onKickUserClicked: root.kickUserClicked(userId)
    }
}
