import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import AppLayouts.Communities.panels 1.0
import AppLayouts.Chat.stores 1.0 as ChatStores
import AppLayouts.Profile.stores 1.0 as ProfileStores

import utils 1.0

import Models 1.0
import SortFilterProxyModel 0.2
import Storybook 1.0

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as SQUtils


SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    // Utils.globalUtilsInst mock
    QtObject {
        function getEmojiHashAsJson(publicKey) {
            return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
        }

        function getColorId(publicKey) {
            return SQUtils.ModelUtils.getByKey(usersModel, "pubKey", publicKey, "colorId")
        }

        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function isCompressedPubKey(publicKey) { return true }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
        }
        Component.onDestruction: {
            Utils.globalUtilsInst = {}
        }
    }

    MembersTabPanel {
        id: membersTabPanelPage
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        placeholderText: "Search users"
        model: usersModelWithMembershipState
        panelType: viewStateSelector.currentValue

        rootStore: ChatStores.RootStore {
            contactsStore: ProfileStores.ContactsStore {
                readonly property string myPublicKey: "0x000"
            }
        }

        onKickUserClicked: {
            logs.logEvent("MembersTabPanel::onKickUserClicked", ["id", "name"], arguments)
        }

        onBanUserClicked: {
            logs.logEvent("MembersTabPanel::onBanUserClicked", ["id", "name"], arguments)
        }

        onUnbanUserClicked: {
            logs.logEvent("MembersTabPanel::onUnbanUserClicked", ["id"], arguments)
        }

        onAcceptRequestToJoin: {
            logs.logEvent("MembersTabPanel::onAcceptRequestToJoin", ["id"], arguments)
        }

        onDeclineRequestToJoin: {
            logs.logEvent("MembersTabPanel::onDeclineRequestToJoin", ["id"], arguments)
        }

        onViewMemberMessagesClicked: {
            logs.logEvent("MembersTabPanel::onViewMemberMessagesClicked", ["pubKey", "displayName"], arguments)
        }
    }

    UsersModel {
        id: usersModel
    }

    SortFilterProxyModel {
        id: usersModelWithMembershipState
        readonly property var membershipStatePerView: [
            [Constants.CommunityMembershipRequestState.Accepted , Constants.CommunityMembershipRequestState.BannedPending, Constants.CommunityMembershipRequestState.UnbannedPending, Constants.CommunityMembershipRequestState.KickedPending],
            [Constants.CommunityMembershipRequestState.Banned],
            [Constants.CommunityMembershipRequestState.Pending, Constants.CommunityMembershipRequestState.AcceptedPending, Constants.CommunityMembershipRequestState.RejectedPending],
            [Constants.CommunityMembershipRequestState.Rejected]
        ]

        sourceModel: usersModel
        sortRole: membersTabPanelPage.panelType

        proxyRoles: [
            FastExpressionRole {
                name: "membershipRequestState"
                expression: {
                    var memberStates = usersModelWithMembershipState.membershipStatePerView[membersTabPanelPage.panelType]
                    return memberStates[model.index % (memberStates.length)]
                }
                expectedRoles: ["index"]
            },
            ConstantRole {
                name: "requestToJoinLoading"
                value: false
            },
            FastExpressionRole {
                function displayNameProxy(localNickname, ensName, displayName, aliasName) {
                    return ProfileUtils.displayName(localNickname, ensName, displayName, aliasName)
                }

                name: "preferredDisplayName"
                expectedRoles: ["localNickname", "displayName", "ensName", "alias"]
                expression: displayNameProxy(model.localNickname, model.ensName, model.displayName, model.alias)
            }
        ]
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 320

        logsView.logText: logs.logText

        ColumnLayout {
            Layout.fillWidth: true
            Label {
                text: "View state"
            }

            ComboBox {
                id: viewStateSelector
                textRole: "text"
                valueRole: "value"
                model: ListModel {
                     id: model
                     ListElement { text: "All members"; value: MembersTabPanel.TabType.AllMembers }
                     ListElement { text: "Banned Members"; value: MembersTabPanel.TabType.BannedMembers }
                     ListElement { text: "Pending Members"; value: MembersTabPanel.TabType.PendingRequests }
                     ListElement { text: "Declined Members"; value: MembersTabPanel.TabType.DeclinedRequests }
                 }
            }
        }
    }

    Settings {
        property alias membersTabPanelSelection: viewStateSelector.currentIndex
    }
}

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?type=design&node-id=35909-605774&mode=design&t=KfrAekLfW5mTy68x-0
