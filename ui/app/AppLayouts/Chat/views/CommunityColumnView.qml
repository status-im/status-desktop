import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Popups 0.1


import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import "../popups/community"
import "../panels/communities"

Item {
    id: root
    width: 304
    height: parent.height

    // Important:
    // We're here in case of CommunitySection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own communitySectionModule)
    property var communitySectionModule

    property var store
    property var communityData: store.mainModuleInst ? store.mainModuleInst.activeSection || {} : {}
    // TODO unhardcode
    // Not Refactored Yet
    //property int chatGroupsListViewCount: communityChatListAndCategories.chatList.count
    property Component pinnedMessagesPopupComponent

    StatusChatInfoToolBar {
        id: communityHeader
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        chatInfoButton.title: communityData.name
        chatInfoButton.subTitle: communityData.nbMembers <= 1 ?
                                     //% "1 Member"
                                     qsTrId("1-member") :
                                     //% "%1 Members"
                                     qsTrId("-1-members").arg(communityData.nbMembers)

        chatInfoButton.image.source: communityData.image
        chatInfoButton.icon.color: communityData.color
        menuButton.visible: communityData.amISectionAdmin && communityData.canManageUsers
        // TODO remove dynamic scoping of popup component
         chatInfoButton.onClicked: Global.openPopup(communityProfilePopup, {
             store: root.store,
             community: communityData
         })

        popupMenu: StatusPopupMenu {
            StatusMenuItem {
                //% "Create channel"
                text: qsTrId("create-channel")
                icon.name: "channel"
                enabled: communityData.amISectionAdmin
                onTriggered: Global.openPopup(createChannelPopup)
            }

            StatusMenuItem {
                //% "Create category"
                text: qsTrId("create-category")
                icon.name: "channel-category"
                enabled: communityData.amISectionAdmin
                // Not Refactored Yet
//                onTriggered: Global.openPopup(createCategoryPopup, {communityId: chatsModel.communities.activeCommunity.id})
            }

           StatusMenuSeparator {}

            StatusMenuItem {
                //% "Invite people"
                text: qsTrId("invite-people")
                icon.name: "share-ios"
                enabled: communityData.canManageUsers
                // Not Refactored Yet
//                onTriggered: Global.openPopup(inviteFriendsToCommunityPopup, {
//                    community: root.store.chatsModelInst.communities.activeCommunity
//                })
            }
        }
    }
    Loader {
        id: membershipRequests

        // Not Refactored Yet
        property int nbRequests: 0
        //property int nbRequests: root.store.chatsModelInst.communities.activeCommunity.communityMembershipRequests.nbRequests

        anchors.top: communityHeader.bottom
        anchors.topMargin: active ? 8 : 0
        anchors.horizontalCenter: parent.horizontalCenter

        // Not Refactored Yet
        active: nbRequests > 0
        //active: communityData.amISectionAdmin && nbRequests > 0
        height: nbRequests > 0 ? 64 : 0
        sourceComponent: Component {
            StatusContactRequestsIndicatorListItem {
                //% "Membership requests"
                title: qsTrId("membership-requests")
                requestsCount: membershipRequests.nbRequests
                sensor.onClicked: Global.openPopup(membershipRequestPopup)
            }
        }
    }

    ScrollView {
        id: chatGroupsContainer
        anchors.top: membershipRequests.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width

        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true
        contentHeight: communityChatListAndCategories.height
                       + emptyViewAndSuggestionsLoader.height
                       + backUpBannerLoader.height
                       + 16

        StatusChatListAndCategories {
            id: communityChatListAndCategories

            anchors.horizontalCenter: parent.horizontalCenter
            width: root.width
            height: {
                if (!emptyViewAndSuggestionsLoader.active &&
                    !backUpBannerLoader.active) {
                    return implicitHeight > (root.height - 82) ? implicitHeight + 8 : root.height - 82
                }
                return implicitHeight
            }

            draggableItems: communityData.amISectionAdmin
            draggableCategories: communityData.amISectionAdmin
            //chatList.model: root.store.chatsModelInst.communities.activeCommunity.chats

            //categoryList.model: root.store.chatsModelInst.communities.activeCommunity.categories
            model: root.communitySectionModule.model
            onChatItemSelected: {
                if(categoryId === "")
                    root.communitySectionModule.setActiveItem(id, "")
                else
                    root.communitySectionModule.setActiveItem(categoryId, id)
            }

            showCategoryActionButtons: communityData.amISectionAdmin
            showPopupMenu: communityData.amISectionAdmin && communityData.canManageUsers
            //selectedChatId: root.store.chatsModelInst.channelView.activeChannel.id

//            onChatItemSelected: root.store.chatsModelInst.channelView.setActiveChannel(id)
//            onChatItemUnmuted: root.store.chatsModelInst.channelView.unmuteChatItem(id)
//            onChatItemReordered: function (categoryId, id, from, to) {
//                root.store.chatsModelInst.communities.reorderCommunityChannel(chatsModel.communities.activeCommunity.id, categoryId, id, to);
//            }
//            onChatListCategoryReordered: function (categoryId, from, to) {
//                root.store.chatsModelInst.communities.reorderCommunityCategories(chatsModel.communities.activeCommunity.id, categoryId, to);
//            }

//            onCategoryAddButtonClicked: Global.openPopup(createChannelPopup, {
//                communityId: root.store.chatsModelInst.communities.activeCommunity.id,
//                categoryId: id
//            })

            popupMenu: StatusPopupMenu {
                StatusMenuItem {
                    //% "Create channel"
                    text: qsTrId("create-channel")
                    icon.name: "channel"
                    // Not Refactored Yet
                    enabled: communityData.amISectionAdmin
                    onTriggered: Global.openPopup(createChannelPopup)
                }

                StatusMenuItem {
                    //% "Create category"
                    text: qsTrId("create-category")
                    icon.name: "channel-category"
                    // Not Refactored Yet
                    enabled: communityData.amISectionAdmin
//                    onTriggered: Global.openPopup(createCategoryPopup, {communityId: root.store.chatsModelInst.communities.activeCommunity.id})
                }

                StatusMenuSeparator {}

                StatusMenuItem {
                    //% "Invite people"
                    text: qsTrId("invite-people")
                    icon.name: "share-ios"
                    // Not Refactored Yet
                    enabled: communityData.amISectionAdmin
//                    onTriggered: Global.openPopup(inviteFriendsToCommunityPopup, {
//                        community: root.store.chatsModelInst.communities.activeCommunity
//                    })
                }
            }

            categoryPopupMenu: StatusPopupMenu {

                property var categoryItem

                openHandler: function (id) {
                    // Not Refactored Yet
//                    categoryItem = root.store.chatsModelInst.communities.activeCommunity.getCommunityCategoryItemById(id)
                }

                StatusMenuItem {
                    // Not Refactored Yet
                    enabled: communityData.amISectionAdmin
                    //% "Edit Category"
                    text: qsTrId("edit-category")
                    icon.name: "edit"
                    onTriggered: {
                        // Not Refactored Yet
//                        Global.openPopup(createCategoryPopup, {
//                            communityId: root.store.chatsModelInst.communities.activeCommunity.id,
//                            isEdit: true,
//                            categoryId: categoryItem.id,
//                            categoryName: categoryItem.name
//                        })
                    }
                }

                StatusMenuSeparator {
                    visible: communityData.amISectionAdmin
                }

                StatusMenuItem {
                    enabled: communityData.amISectionAdmin
                    //% "Delete Category"
                    text: qsTrId("delete-category")
                    icon.name: "delete"
                    type: StatusMenuItem.Type.Danger
                    onTriggered: {
                        Global.openPopup(deleteCategoryConfirmationDialogComponent, {
                            //% "Delete %1 category"
                            title: qsTrId("delete--1-category").arg(categoryItem.name),
                            //% "Are you sure you want to delete %1 category? Channels inside the category won’t be deleted."
                            confirmationText: qsTrId("are-you-sure-you-want-to-delete--1-category--channels-inside-the-category-won-t-be-deleted-")
                                .arg(categoryItem.name),
                            categoryId: categoryItem.id
                        })
                    }
                }
            }

            chatListPopupMenu: ChatContextMenuView {
                id: chatContextMenuView

                openHandler: function (id) {
                    let jsonObj = root.communitySectionModule.getItemAsJson(id)
                    let obj = JSON.parse(jsonObj)
                    if (obj.error) {
                        console.error("error parsing chat item json object, id: ", id, " error: ", obj.error)
                        close()
                        return
                    }

                    currentFleet = root.communitySectionModule.getCurrentFleet()
                    isCommunityChat = root.communitySectionModule.isCommunity()
                    isCommunityAdmin = obj.amIChatAdmin
                    chatId = obj.itemId
                    chatName = obj.name
                    chatDescription = obj.description
                    chatType = obj.type
                    chatMuted = obj.muted
                }

                onMuteChat: {
                    root.communitySectionModule.muteChat(chatId)
                }

                onUnmuteChat: {
                    root.communitySectionModule.unmuteChat(chatId)
                }

                onMarkAllMessagesRead: {
                    root.communitySectionModule.markAllMessagesRead(chatId)
                }

                onClearChatHistory: {
                    root.communitySectionModule.clearChatHistory(chatId)
                }

                onRequestAllHistoricMessages: {
                    // Not Refactored Yet - Check in the `master` branch if this is applicable here.
                }

                onLeaveChat: {
                    root.communitySectionModule.leaveChat(chatId)
                }

                onDeleteChat: {
                    // Not Refactored Yet
                }

                onDownloadMessages: {
                    // Not Refactored Yet
                }

                onDisplayProfilePopup: {
                    // Not Refactored Yet
                }

                onDisplayGroupInfoPopup: {
                    // Not Refactored Yet
                }

                onEditCommunityChannel: {
                    // Not Refactored Yet
                }

                onOpenPinnedMessagesList: {
                    chatCommunitySectionModule.prepareChatContentModuleForChatId(chatId)
                    let chatContentModule = chatCommunitySectionModule.getChatContentModule()
                    Global.openPopup(pinnedMessagesPopupComponent, {
                                         messageStore: messageStore,
                                         pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                         messageToPin: ""
                                     })
                }
            }
        }

        Loader {
            id: emptyViewAndSuggestionsLoader
            active: communityData.amISectionAdmin &&
                     (!localAccountSensitiveSettings.hiddenCommunityWelcomeBanners ||
                      !localAccountSensitiveSettings.hiddenCommunityWelcomeBanners.includes(communityData.id))
            width: parent.width
            height: {
                // I dont know why, the binding doesn't work well if this isn't here
                item.height
                return this.active ? item.height : 0
            }
            anchors.top: communityChatListAndCategories.bottom
            anchors.topMargin: active ? Style.current.padding : 0
            sourceComponent: Component {
                CommunityWelcomeBannerPanel {
                    activeCommunity: communityData
                    store: root.store
                }
            }
        }

        Loader {
            id: backUpBannerLoader
            active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityBackUpBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityBackUpBanners.includes(communityData.id))
            width: parent.width
            height: active ? item.height : 0
            anchors.top: emptyViewAndSuggestionsLoader.bottom
            anchors.topMargin: active ? Style.current.padding : 0
            sourceComponent: Component {
                Item {
                    width: parent.width
                    height: backupBanner.height

                    BackUpCommuntyBannerPanel {
                        id: backupBanner
                        activeCommunity: communityData
                        onBackupButtonClicked: {
                            Global.openPopup(transferOwnershipPopup, {
                                privateKey: root.store.exportCommunity(),
                                store: root.store
                            })
                        }
                    }
                    MouseArea {
                        anchors.fill: backupBanner
                        acceptedButtons: Qt.RightButton
                        onClicked: {
                            /* Prevents sending events to the component beneath
                               if Right Mouse Button is clicked. */
                            mouse.accepted = false;
                        }
                    }
                }
            }
        }
    }

    Component {
        id: createChannelPopup
        CreateChannelPopup {
            anchors.centerIn: parent
            onCreateCommunityChannel: function (chName, chDescription) {
                root.store.createCommunityChannel(communityData.id, chName, chDescription)
            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCategoryPopup
        CreateCategoryPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: deleteCategoryConfirmationDialogComponent
        ConfirmationDialog {
            property string categoryId
            btnType: "warn"
            showCancelButton: true
            onClosed: {
                destroy()
            }
            onCancelButtonClicked: {
                close();
            }
            onConfirmButtonClicked: function(){
                // Not Refactored Yet
//                const error = root.store.chatsModelInst.communities.deleteCommunityCategory(root.store.chatsModelInst.communities.activeCommunity.id, categoryId)
//                if (error) {
//                    creatingError.text = error
//                    return creatingError.open()
//                }
//                close();
            }
        }
    }

    MessageDialog {
        id: deleteError
        //% "Error deleting the category"
        title: qsTrId("error-deleting-the-category")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    Component {
        id: membershipRequestPopup
        MembershipRequestsPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: transferOwnershipPopup
        TransferOwnershipPopup {
            anchors.centerIn: parent
            onClosed: {
                let hiddenBannerIds = localAccountSensitiveSettings.hiddenCommunityBackUpBanners || []
                if (hiddenBannerIds.includes(root.store.activeCommunity.id)) {
                    return
                }
                hiddenBannerIds.push(root.store.activeCommunity.id)
                localAccountSensitiveSettings.hiddenCommunityBackUpBanners = hiddenBannerIds
            }
        }
    }
}
