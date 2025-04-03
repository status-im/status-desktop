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
        id: communityModule

        // General properties:
        property string name: "Uniswap"
        property string communityDesc: "General channel for the community"
        property string introMessage: "%1 sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

1. Ut enim ad minim veniam
2. Excepteur sint occaecat cupidatat non proident
3. Duis aute irure
4. Dolore eu fugiat nulla pariatur
5. 🚗 consectetur adipiscing elit

Nemo enim 😋 ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.".arg(d.name)

        property color color: "orchid"
        property string channelName: joinCommunity ? "general" : "#vip"
        property string channelDesc: "VIP members only"
        property bool joinCommunity: true // Otherwise it means join channel action
        property int accessType: Constants.communityChatPublicAccess

        // Overlay component:
        property bool requirementsMet: true
        property int requestToJoinState: Constants.RequestToJoinState.None
        property bool isInvitationPending: requestToJoinState !== Constants.RequestToJoinState.None

        property bool isJoinRequestRejected: false
        property bool requiresRequest: false

        property var communityHoldingsModel: PermissionsModel.shortPermissionsModel
        property var viewOnlyHoldingsModel: PermissionsModel.shortPermissionsModel
        property var viewAndPostHoldingsModel: PermissionsModel.shortPermissionsModel
        property var moderateHoldingsModel: PermissionsModel.shortPermissionsModel
        property var assetsModel: AssetsModel {}
        property var collectiblesModel: CollectiblesModel {}

        // Blur background:
        property int membersCount: 184
        property bool amISectionAdmin: false
        property url image: Theme.png("tokens/UNI")
        property var communityItemsModel: model1
        property string chatDateTimeText: "Dec 31, 2020"
        property string  listUsersText: "simon, Mark Cuban "
        readonly property ListModel model1:  ListModel {
            ListElement { name: "welcome"; selected: false; notificationsCount: 0; hasUnreadMessages: false}
            ListElement { name: "general"; selected: false; notificationsCount: 0; hasUnreadMessages: true}
            ListElement { name: "design"; selected: true; notificationsCount: 3; hasUnreadMessages: true}
            ListElement { name: "random"; selected: false; notificationsCount: 0; hasUnreadMessages: false}
            ListElement { name: "vip"; selected: false; notificationsCount: 0; hasUnreadMessages: true}
        }
        readonly property ListModel model2:  ListModel {
            ListElement { name: "general"; selected: false; notificationsCount: 3; hasUnreadMessages: false}
            ListElement { name: "blockchain"; selected: true; notificationsCount: 3; hasUnreadMessages: true}
            ListElement { name: "faq"; selected: false; notificationsCount: 0; hasUnreadMessages: false}
        }
        readonly property var messagesModel: ListModel {
            ListElement {
                timestamp: 1656937930
                senderDisplayName: "simon"
                contentType: StatusMessage.ContentType.Text
                message:  "Hello, this is awesome! Feels like decentralized Discord!"
                isContact: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
                colorId: 4
            }
            ListElement {
                timestamp: 1657937930
                senderDisplayName: "Mark Cuban"
                contentType: StatusMessage.ContentType.Text
                message: "I know a lot of you really seem to get off or be validated by arguing with strangers online but please know it's a complete waste of your time and energy"
                isContact: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
                colorId: 2
            }
        }
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

                function isCommunity() {
                    return true
                }

                function createOneToOneChat(a, pubKey, b) {
                }

            }

            function currentChatContentModule() {
                return {
                    chatDetails: {
                        id: "dummyChatId",
                        name: "Dummy Chat",
                        description: "This is a dummy chat description.",
                        emoji: "😀",
                        color: "#FF5722",
                        icon: "",
                        type: Constants.chatType.privateGroupChat,
                        muted: false,
                        requiresPermissions: true,
                        canPost: true,
                        hideIfPermissionsNotMet: false,
                        belongsToCommunity: false,
                        isUsersListAvailable: true,
                        position: 1
                    },
                    messagesModule: {
                        // Define dummy messages module if needed
                    },
                    pinnedMessagesModel: {
                        count: 0
                    },
                    usersModule: {
                        model: {
                            count: 10
                        }
                    },
                    getCurrentFleet: function() {
                        return "dummyFleet";
                    },
                    amIChatAdmin: function() {
                        return true;
                    },
                    muteChat: function(interval) {
                        console.debug("Dummy mute chat function called with interval:", interval);
                    },
                    unmuteChat: function() {
                        console.debug("Dummy unmute chat function called");
                    },
                    markAllMessagesRead: function() {
                        console.debug("Dummy mark all messages read function called");
                    },
                    clearChatHistory: function() {
                        console.debug("Dummy clear chat history function called");
                    },
                    leaveChat: function() {
                        console.debug("Dummy leave chat function called");
                    },
                    downloadMessages: function(file) {
                        console.debug("Dummy download messages function called with file:", file);
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
        id: d

        property var communityId
        property var communitySectionModule
        property var chatCommunitySectionModule
        property int activeChannelId
        property int activeSectionId


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
                joinedMembersCount: 100,
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




        property int joinedMembersCount

        property var emojiPopup
        property var stickersPopup
        property bool stickersLoaded: false

        // readonly property var chatContentModule: rootStore.currentChatContentModule() || null
        // readonly property bool canView: chatContentModule.chatDetails.canView
        // readonly property bool canPost: chatContentModule.chatDetails.canPost
        // readonly property bool missingEncryptionKey: chatContentModule.chatDetails.missingEncryptionKey

        property bool hasViewOnlyPermissions: false
        property bool hasUnrestrictedViewOnlyPermission: false

        property bool hasViewAndPostPermissions: false
        property bool amIMember: false
        property bool amISectionAdmin: true
        //readonly property bool allChannelsAreHiddenBecauseNotPermitted: rootStore.allChannelsAreHiddenBecauseNotPermitted
        property bool isPendingOwnershipRequest: false
        property bool areTestNetworksEnabled: false


        property int requestToJoinState: Constants.RequestToJoinState.None

        property var viewOnlyPermissionsModel
        property var viewAndPostPermissionsModel
        property var assetsModel
        property var collectiblesModel

        property bool sendViaPersonalChatEnabled
        property bool paymentRequestFeatureEnabled
    }

    QtObject {
        id: models

        property ContactsModelAdaptor contactsModelAdaptor: ContactsModelAdaptor {
            allContacts: UsersModel {}
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
                sectionItemModel: d.sectionItemModel
                mutualContactsModel: models.contactsModelAdaptor.mutualContacts
                viewOnlyPermissionsModel: d.viewOnlyPermissionsModel
                viewAndPostPermissionsModel: d.viewAndPostPermissionsModel
                assetsModel: d.assetsModel
                collectiblesModel: d.collectiblesModel


                // onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(communityId)
                // onCommunityInfoButtonClicked: root.currentIndex = 1
                // onCommunityManageButtonClicked: root.currentIndex = 1

                // onProfileButtonClicked: {
                //     root.profileButtonClicked()
                // }
                // onOpenAppSearch: {
                //     root.openAppSearch()
                // }
                // onRequestToJoinClicked: {
                //     Global.communityIntroPopupRequested(communityId, root.sectionItemModel.name, root.sectionItemModel.introMessage,
                //                                         root.sectionItemModel.image, root.isInvitationPending)
                // }
                // onInvitationPendingClicked: {
                //     Global.communityIntroPopupRequested(communityId, root.sectionItemModel.name, root.sectionItemModel.introMessage,
                //                                         root.sectionItemModel.image, root.isInvitationPending)
                // }

                onBuyStickerPackRequested: logs.logEvent("onBuyStickerPackRequested:: (packId, price): " + packId + " , " + price)
                //onTokenPaymentRequested: root.tokenPaymentRequested(recipientAddress, symbol, rawAmount, chainId)
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

                // Community settings editor:
                Label {
                    Layout.fillWidth: true
                    text: "COMMUNITY INFO EDITOR"
                    font.bold: true
                    font.pixelSize: 18
                }

                CommunityInfoEditor {
                    name: d.name
                    membersCount: d.membersCount
                    amISectionAdmin: d.amISectionAdmin
                    color: d.color
                    image: d.image
                    colorVisible: true

                    onNameChanged: d.name = name
                    onMembersCountChanged: d.membersCount = membersCount
                    onAmISectionAdminChanged: d.amISectionAdmin = amISectionAdmin
                    onColorChanged: d.color = color
                    onImageChanged: d.image = image
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Community items model:"
                    }

                    RadioButton {
                        checked: true
                        text: qsTr("Model 1")
                        onCheckedChanged: if(checked) d.communityItemsModel =  d.model1
                    }
                    RadioButton {
                        text: qsTr("Model 2")
                        onCheckedChanged: if(checked) d.communityItemsModel = d.model2
                    }
                }
            }
        }
    }
}

    // category: Views
