import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Chat.views 1.0

import AppLayouts.Chat.stores 1.0 as ChatStores
import AppLayouts.Profile.stores 1.0
import shared.stores 1.0 as SharedStores
import AppLayouts.Communities.stores 1.0 as CommunitiesStores
import AppLayouts.Wallet.stores 1.0 as WalletStore
import mainui.adaptors 1.0

import Storybook 1.0
import Models 1.0

import utils 1.0

SplitView {

    QtObject {
        id: d

        property var communityId
        property var communitySectionModule
        property var chatCommunitySectionModule
        property int activeChannelId
        property int activeSectionId
        property int joinedMembersCount: 100

        property var emojiPopup
        property var stickersPopup
        property bool stickersLoaded: false

        property bool hasViewOnlyPermissions: false
        property bool hasUnrestrictedViewOnlyPermission: false
        property bool hasViewAndPostPermissions: false
        property bool amIMember: false
        property bool amISectionAdmin: true
        property bool isPendingOwnershipRequest: false
        property bool areTestNetworksEnabled: false
        property int requestToJoinState: Constants.RequestToJoinState.None
        property bool sendViaPersonalChatEnabled
        property bool paymentRequestFeatureEnabled
    }

    QtObject {
        id: stores

        property ContactsStore contactsStore
        property SharedStores.RootStore sharedRootStore
        property SharedStores.UtilsStore utilsStore
        property ChatStores.RootStore rootStore: ChatStores.RootStore {
            id: chatRootStore

            readonly property SharedStores.PermissionsStore permissionsStore: SharedStores.PermissionsStore {
                activeSectionId: d.activeSectionId
                activeChannelId: d.activeChannelId
                chatCommunitySectionModuleInst: chatRootStore.chatCommunitySectionModule
            }
            property var chatCommunitySectionModule: QtObject {

                // This will make the left column view look as community or as a chat
                function isCommunity() {
                    return true
                }

                function createOneToOneChat(a, pubKey, b) {
                }

                property bool chatsLoaded: true

                // Dummy model data for chats and categories:
                property var model: ListModel {
                    ListElement {
                        itemId: "channel1"
                        categoryId: "category1"
                        name: "Dummy Channel 1"
                        emoji: "🔥"
                        color: "#E91E63"
                        icon: ""
                        position: 1
                        categoryPosition: 1
                        isCategory: false
                        muted: false
                        hasUnreadMessages: false
                        notificationsCount: 1
                        type: 6
                        shouldBeHiddenBecausePermissionsAreNotMet: false
                    }
                    ListElement {
                        itemId: "channel2"
                        categoryId: "category2"
                        name: "Dummy Channel 2"
                        emoji: "😎"
                        color: "#4CAF50"
                        icon: ""
                        position: 2
                        categoryPosition: 1
                        isCategory: false
                        muted: false
                        hasUnreadMessages: false
                        notificationsCount: 3
                        type: 6
                        shouldBeHiddenBecausePermissionsAreNotMet: false
                    }
                }
            }

            // Dummy basic model for chat content
            function currentChatContentModule() {
                return {
                    chatDetails: {
                        id: "channel1",
                        name: "Dummy Channel 1",
                        description: "This is a dummy channel description.",
                        emoji: "🔥",
                        color: "#E91E63",
                        icon: "",
                        type: 6,
                        muted: false,
                        belongsToCommunity: true,
                        isUsersListAvailable: true,
                        position: 1,
                        canView: true,
                        canPost: true,
                        missingEncryptionKey: false,
                        permissionsCheckOngoing: false
                    },
                    messagesModule: {
                        // Define dummy messages module if needed
                    },
                    pinnedMessagesModel: {
                        count: 4
                    }
                };
            }

        }
        property ChatStores.CreateChatPropertiesStore createChatPropertiesStore
        property CommunitiesStores.CommunitiesStore communitiesStore
        property WalletStore.WalletAssetsStore walletAssetsStore
        property SharedStores.CurrenciesStore currencyStore
    }

    QtObject {
        id: models

        property ContactsModelAdaptor contactsModelAdaptor: ContactsModelAdaptor {
            allContacts: UsersModel {}
        }

        property var viewOnlyPermissionsModel
        property var viewAndPostPermissionsModel
        property var assetsModel
        property var collectiblesModel

        property var sectionItemModel: currentCommunityData()

        function currentCommunityData() {
            return {
                id: "dummyCommunityId",
                name: "Dummy Community",
                image: "dummyImage.png",
                color: "#FF5722",
                introMessage: "Welcome to the Dummy Community!",
                //access: Constants.communityChatAccess.public,
                joined: true,
                memberRole: Constants.memberRole.owner,
                canManageUsers: true,
                amIBanned: false,
                channels: [
                    {
                        id: "dummyChannelId1",
                        name: "General",
                        description: "General discussion",
                        emoji: "💬",
                        color: "#FF5722",
                        icon: "",
                        type: Constants.chatType.communityChat,
                        muted: false,
                        position: 1,
                        categoryId: "dummyCategoryId1",
                        viewersCanPostReactions: true,
                        hideIfPermissionsNotMet: false
                    },
                    {
                        id: "dummyChannelId2",
                        name: "Announcements",
                        description: "Official announcements",
                        emoji: "📢",
                        color: "#4CAF50",
                        icon: "",
                        type: Constants.chatType.communityChat,
                        muted: false,
                        position: 2,
                        categoryId: "dummyCategoryId1",
                        viewersCanPostReactions: true,
                        hideIfPermissionsNotMet: false
                    }
                ],
                categories: [
                    {
                        id: "dummyCategoryId1",
                        name: "Main",
                        position: 1,
                        muted: false
                    }
                ]
            };
        }
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            ChatView {
                id: chatView

                readonly property var sectionItem: d.communitySectionModule
                readonly property string communityId: d.communityId

                // Stores
                contactsStore: stores.contactsStore
                sharedRootStore: stores.sharedRootStore
                utilsStore: stores.utilsStore
                rootStore: stores.rootStore
                createChatPropertiesStore: stores.createChatPropertiesStore
                communitiesStore: stores.communitiesStore
                walletAssetsStore: stores.walletAssetsStore
                currencyStore: stores.currencyStore

                // Properties
                emojiPopup: d.emojiPopup
                stickersPopup: d.stickersPopup
                joinedMembersCount: d.joinedMembersCount
                requestToJoinState: d.requestToJoinState

                // Flags
                amIMember: d.amIMember
                amISectionAdmin: d.amISectionAdmin
                hasViewOnlyPermissions: d.hasViewOnlyPermissions
                sendViaPersonalChatEnabled: d.sendViaPersonalChatEnabled
                paymentRequestFeatureEnabled: d.paymentRequestFeatureEnabled
                hasUnrestrictedViewOnlyPermission: d.hasUnrestrictedViewOnlyPermission
                hasViewAndPostPermissions: d.hasViewAndPostPermissions
                isPendingOwnershipRequest: d.isPendingOwnershipRequest
                areTestNetworksEnabled: d.areTestNetworksEnabled

                // Models
                sectionItemModel: models.sectionItemModel
                mutualContactsModel: models.contactsModelAdaptor.mutualContacts
                viewOnlyPermissionsModel: models.viewOnlyPermissionsModel
                viewAndPostPermissionsModel: models.viewAndPostPermissionsModel
                assetsModel: models.assetsModel
                collectiblesModel: models.collectiblesModel
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {
            anchors.fill: parent

            ColumnLayout {
                spacing: 16

                // TODO: Create channel fields
                // TODO: Create members fields
            }
        }
    }
}

    // category: Views
