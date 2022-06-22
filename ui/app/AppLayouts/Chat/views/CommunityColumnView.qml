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
    property var emojiPopup

    property var store
    property bool hasAddedContacts: false
    property var communityData: store.mainModuleInst ? store.mainModuleInst.activeSection || {} : {}
    property Component pinnedMessagesPopupComponent

    signal infoButtonClicked
    signal manageButtonClicked

    StatusChatInfoToolBar {
        id: communityHeader
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        chatInfoButton.title: communityData.name
        chatInfoButton.subTitle: communityData.members.count <= 1 ?
                                     //% "1 Member"
                                     qsTrId("1-member") :
                                     //% "%1 Members"
                                     qsTrId("-1-members").arg(communityData.members.count)

        chatInfoButton.image.source: communityData.image
        chatInfoButton.icon.color: communityData.color
        menuButton.visible: communityData.amISectionAdmin && communityData.canManageUsers
        chatInfoButton.onClicked: root.infoButtonClicked()

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
                onTriggered: Global.openPopup(createCategoryPopup)
            }

           StatusMenuSeparator {}

            StatusMenuItem {
                //% "Invite people"
                text: qsTrId("invite-people")
                icon.name: "share-ios"
                enabled: communityData.canManageUsers
                onTriggered: Global.openPopup(inviteFriendsToCommunityPopup, {
                    community: communityData,
                    hasAddedContacts: root.hasAddedContacts,
                    communitySectionModule: root.communitySectionModule
                })
            }
        }

    } // StatusChatInfoToolBar
    Loader {
        id: membershipRequests

        property int nbRequests: root.communityData.pendingRequestsToJoin.count || 0

        anchors.top: communityHeader.bottom
        anchors.topMargin: active ? 8 : 0
        anchors.horizontalCenter: parent.horizontalCenter

        active: communityData.amISectionAdmin && nbRequests > 0
        height: nbRequests > 0 ? 64 : 0
        sourceComponent: Component {
            StatusContactRequestsIndicatorListItem {
                //% "Membership requests"
                title: qsTrId("membership-requests")
                requestsCount: membershipRequests.nbRequests
                sensor.onClicked: Global.openPopup(membershipRequestPopup, {
                    communitySectionModule: root.communitySectionModule
                })
            }
        }
    }

    ScrollView {
        id: chatGroupsContainer
        anchors.top: membershipRequests.bottom
        anchors.bottom: parent.bottom

        topPadding: Style.current.padding

        width: parent.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true
        contentHeight: communityChatListAndCategories.height
                       + bannerColumn.height
                       + Style.current.bigPadding

        background: MouseArea {
            acceptedButtons: Qt.RightButton
            onClicked: {
                popup.x = mouse.x + 4
                popup.y = mouse.y + 4
                popup.open()
            }

        property var popup: StatusPopupMenu {
            StatusMenuItem {
                text: qsTr("Create channel")
                icon.name: "channel"
                enabled: communityData.amISectionAdmin
                onTriggered: Global.openPopup(createChannelPopup)
            }

            StatusMenuItem {
                text: qsTr("Create category")
                icon.name: "channel-category"
                enabled: communityData.amISectionAdmin
                onTriggered: Global.openPopup(createCategoryPopup)
            }

            StatusMenuSeparator {}

            StatusMenuItem {
                text: qsTr("Invite people")
                icon.name: "share-ios"
                enabled: communityData.canManageUsers
                onTriggered: Global.openPopup(inviteFriendsToCommunityPopup, {
                                                  community: communityData,
                                                  hasAddedContacts: root.hasAddedContacts,
                                                  communitySectionModule: root.communitySectionModule
                                              })
            }
        }
    } // MouseArea

        StatusChatListAndCategories {
            id: communityChatListAndCategories
            anchors.horizontalCenter: parent.horizontalCenter
            draggableItems: communityData.amISectionAdmin
            draggableCategories: communityData.amISectionAdmin

            model: root.communitySectionModule.model
            onChatItemSelected: {
                if(categoryId === "")
                    root.communitySectionModule.setActiveItem(id, "")
                else
                    root.communitySectionModule.setActiveItem(categoryId, id)
            }

            showCategoryActionButtons: communityData.amISectionAdmin
            showPopupMenu: communityData.amISectionAdmin && communityData.canManageUsers

            // onChatItemSelected: root.store.chatsModelInst.channelView.setActiveChannel(id)
            // onChatItemUnmuted: root.store.chatsModelInst.channelView.unmuteChatItem(id)
            onChatItemReordered: function(categoryId, chatId, from, to){
                root.store.reorderCommunityChat(categoryId, chatId, to)
            }
            onChatListCategoryReordered: root.store.reorderCommunityCategories(categoryId, to)

            onCategoryAddButtonClicked: Global.openPopup(createChannelPopup, {
                categoryId: id
            })

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
                    enabled: communityData.amISectionAdmin
                    onTriggered: Global.openPopup(createCategoryPopup)
                }

                StatusMenuSeparator {}

                StatusMenuItem {
                    //% "Invite people"
                    text: qsTrId("invite-people")
                    icon.name: "share-ios"
                    enabled: communityData.canManageUsers
                    onTriggered: Global.openPopup(inviteFriendsToCommunityPopup, {
                        community: communityData,
                        hasAddedContacts: root.hasAddedContacts,
                        communitySectionModule: root.communitySectionModule
                    })
                }
            }

            categoryPopupMenu: StatusPopupMenu {

                property var categoryItem

                openHandler: function (id) {
                    let jsonObj = root.communitySectionModule.getItemAsJson(id)
                    let obj = JSON.parse(jsonObj)
                    if (obj.error) {
                        console.error("error parsing chat item json object, id: ", id, " error: ", obj.error)
                        close()
                        return
                    }
                    categoryItem = obj
                }

                StatusMenuItem {
                    enabled: communityData.amISectionAdmin
                    //% "Edit Category"
                    text: qsTrId("edit-category")
                    icon.name: "edit"
                    onTriggered: {
                       Global.openPopup(createCategoryPopup, {
                           isEdit: true,
                           channels: [],
                           categoryId: categoryItem.categoryId,
                           categoryName: categoryItem.name
                       })
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
                            categoryId: categoryItem.categoryId
                        })
                    }
                }
            }

            chatListPopupMenu: ChatContextMenuView {
                id: chatContextMenuView
                emojiPopup: root.emojiPopup

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
                    amIChatAdmin = obj.amIChatAdmin
                    chatId = obj.itemId
                    chatName = obj.name
                    chatDescription = obj.description

                    chatEmoji = obj.emoji
                    chatColor = obj.color
                    chatType = obj.type
                    chatMuted = obj.muted
                    channelPosition = obj.position
                    chatCategoryId = obj.categoryId
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

                onDeleteCommunityChat:  root.store.removeCommunityChat(chatId)

                onDownloadMessages: {
                    root.communitySectionModule.downloadMessages(chatId, file)
                }

                onDisplayProfilePopup: {
                    Global.openProfilePopup(publicKey)
                }

                onDisplayGroupInfoPopup: {
                communitySectionModule.prepareChatContentModuleForChatId(chatId)
                let chatContentModule = communitySectionModule.getChatContentModule()
                Global.openPopup(groupInfoPopupComponent, {
                                     chatContentModule: chatContentModule,
                                     chatDetails: chatContentModule.chatDetails
                                 })
                }

                onEditCommunityChannel: {
                    communitySectionModule.editCommunityChannel(
                        chatId,
                        newName,
                        newDescription,
                        newEmoji,
                        newColor,
                        newCategory,
                        channelPosition // TODO change this to the signal once it is modifiable
                    )
                }
            }
        }

        Column {
            id: bannerColumn
            width: parent.width
            anchors.top: communityChatListAndCategories.bottom
            anchors.topMargin: Style.current.padding
            spacing: Style.current.bigPadding

            Loader {
                id: emptyViewAndSuggestionsLoader
                active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityWelcomeBanners ||
                        !localAccountSensitiveSettings.hiddenCommunityWelcomeBanners.includes(communityData.id))
                width: parent.width
                height: {
                    // I dont know why, the binding doesn't work well if this isn't here
                    item && item.height
                    return this.active ? item.height : 0
                }
                sourceComponent: Component {
                    CommunityWelcomeBannerPanel {
                        activeCommunity: communityData
                        store: root.store
                        hasAddedContacts: root.hasAddedContacts
                        communitySectionModule: root.communitySectionModule
                        onManageCommunityClicked: root.manageButtonClicked()
                    }
                }
            } // Loader

            Loader {
                id: channelsAndCategoriesAdminBox
                active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners ||
                        !localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners.includes(communityData.id))
                width: parent.width
                height: {
                    // I dont know why, the binding doesn't work well if this isn't here
                    item && item.height
                    return this.active ? item.height : 0
                }
                sourceComponent: Component {
                    Item {
                        width: parent.width
                        height: channelsAndCategoriesBanner.height

                        CommunityChannelsAndCategoriesBannerPanel {
                            id: channelsAndCategoriesBanner
                            communityId: communityData.id
                        }

                        MouseArea {
                            anchors.fill: channelsAndCategoriesBanner
                            acceptedButtons: Qt.RightButton
                            propagateComposedEvents: true
                            onClicked: {
                                /* Prevents sending events to the component beneath
                                if Right Mouse Button is clicked. */
                                mouse.accepted = false;
                            }
                        }
                    }
                }
            } // Loader

            Loader {
                id: backUpBannerLoader
                active: communityData.amISectionAdmin &&
                            (!localAccountSensitiveSettings.hiddenCommunityBackUpBanners ||
                            !localAccountSensitiveSettings.hiddenCommunityBackUpBanners.includes(communityData.id))
                width: parent.width
                height: {
                    // I dont know why, the binding doesn't work well if this isn't here
                    item && item.height
                    active ? item.height : 0
                }
                sourceComponent: Component {
                    Item {
                        width: parent.width
                        height: backupBanner.height

                        BackUpCommuntyBannerPanel {
                            id: backupBanner
                            communityId: communityData.id
                            onBackupButtonClicked: {
                                Global.openPopup(transferOwnershipPopup, {
                                    privateKey: communitySectionModule.exportCommunity(communityData.id),
                                    store: root.store
                                })
                            }
                        }
                        MouseArea {
                            anchors.fill: backupBanner
                            acceptedButtons: Qt.RightButton
                            propagateComposedEvents: true
                            onClicked: {
                                /* Prevents sending events to the component beneath
                                if Right Mouse Button is clicked. */
                                mouse.accepted = false;
                            }
                        }
                    }
                }
            } // Loader
        } // Column
    } // ScrollView

    Component {
        id: createChannelPopup
        CreateChannelPopup {
            anchors.centerIn: parent
            emojiPopup: root.emojiPopup
            onCreateCommunityChannel: function (chName, chDescription, chEmoji, chColor,
                    chCategoryId) {
                root.store.createCommunityChannel(chName, chDescription, chEmoji, chColor,
                    chCategoryId)
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
                const error = root.store.deleteCommunityCategory(categoryId);
                if (error) {
                    deleteError.text = error
                    return deleteError.open()
                }
                close();
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
            pendingRequestsToJoin: root.communityData.pendingRequestsToJoin
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

    Connections {
        target: root.store.mainModuleInst

        onOpenCommunityMembershipRequestsPopup:{
            if(root.store.getMySectionId() != sectionId)
                return

            Global.openPopup(membershipRequestPopup, {
                                 communitySectionModule: root.communitySectionModule
                             })
        }
    }
}
