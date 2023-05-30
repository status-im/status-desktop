import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat.menuItems 1.0

import "../popups/community"
import "../panels"
import "../panels/communities"

// FIXME: Rework me to use ColumnLayout instead of anchors!!
Item {
    id: root
    objectName: "communityColumnView"
    width: Constants.chatSectionLeftColumnWidth
    height: parent.height

    // Important:
    // We're here in case of CommunitySection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own communitySectionModule)
    property var communitySectionModule
    property var emojiPopup

    property var store
    property bool hasAddedContacts: false
    property var communityData

    signal infoButtonClicked
    signal manageButtonClicked

    CommunityColumnHeaderPanel {
        id: communityHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        name: communityData.name
        membersCount: communityData.members.count
        image: communityData.image
        color: communityData.color
        amISectionAdmin: communityData.amISectionAdmin
        openCreateChat: root.store.openCreateChat
        onInfoButtonClicked: root.infoButtonClicked()
        onAdHocChatButtonClicked: root.store.openCloseCreateChatView()
    }

    StatusButton {
        id: joinCommunityButton

        property bool invitationPending: root.store.isCommunityRequestPending(communityData.id)

        anchors.top: communityHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: !root.communityData.amIBanned

        visible: !communityData.joined || root.communityData.amIBanned

        text: {
            if (root.communityData.amIBanned) return qsTr("You were banned from community")
            if (invitationPending) return qsTr("Membership request pending...")

            return root.communityData.access === Constants.communityChatOnRequestAccess ?
                    qsTr("Request to join") : qsTr("Join Community")
        }

        onClicked: {
            Global.openPopup(communityIntroDialog);
        }

        Connections {
            target: root.store.communitiesModuleInst
            function onCommunityAccessRequested(communityId: string) {
                if (communityId === communityData.id) {
                    joinCommunityButton.invitationPending = root.store.isCommunityRequestPending(communityData.id)
                    joinCommunityButton.loading = false
                }
            }
        }
        Component {
            id: communityIntroDialog
            CommunityIntroDialog {

                isInvitationPending: joinCommunityButton.invitationPending
                name: communityData.name
                introMessage: communityData.introMessage
                imageSrc: communityData.image
                accessType: communityData.access

                onJoined: {
                    joinCommunityButton.loading = true
                    root.store.requestToJoinCommunity(communityData.id, root.store.userProfileInst.name)
                }
                onCancelMembershipRequest: {
                    root.store.cancelPendingRequest(communityData.id)
                    joinCommunityButton.invitationPending = root.store.isCommunityRequestPending(communityData.id)
                }
            }
        }
    }

    ChatsLoadingPanel {
        chatSectionModule: root.communitySectionModule
        width: parent.width
        anchors.top: joinCommunityButton.visible ? joinCommunityButton.bottom : communityHeader.bottom
        anchors.topMargin: active ? Style.current.halfPadding : 0
    }

    StatusMenu {
        id: adminPopupMenu
        enabled: communityData.amISectionAdmin

        property bool showInviteButton: false

        onClosed: adminPopupMenu.showInviteButton = false

        StatusAction {
            objectName: "createCommunityChannelBtn"
            text: qsTr("Create channel")
            icon.name: "channel"
            onTriggered: Global.openPopup(createChannelPopup)
        }

        StatusAction {
            objectName: "createCommunityCategoryBtn"
            text: qsTr("Create category")
            icon.name: "channel-category"
            onTriggered: Global.openPopup(createCategoryPopup)
        }

        StatusMenuSeparator {
            visible: invitePeopleBtn.enabled
        }

        StatusAction {
            id: invitePeopleBtn
            text: qsTr("Invite people")
            icon.name: "share-ios"
            enabled: communityData.canManageUsers && adminPopupMenu.showInviteButton
            onTriggered: {
                Global.openInviteFriendsToCommunityPopup(root.communityData,
                                                         root.communitySectionModule,
                                                         null)
            }
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.top: joinCommunityButton.visible ? joinCommunityButton.bottom : communityHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottom: createChatOrCommunity.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        contentWidth: availableWidth
        contentHeight: communityChatListAndCategories.height
                       + bannerColumn.height
                       + bannerColumn.anchors.topMargin

        StatusChatListAndCategories {
            id: communityChatListAndCategories
            width: scrollView.availableWidth
            draggableItems: communityData.amISectionAdmin
            draggableCategories: communityData.amISectionAdmin

            model: root.communitySectionModule.model
            highlightItem: !root.store.openCreateChat

            onChatItemSelected: {
                Global.closeCreateChatView()
                root.communitySectionModule.setActiveItem(id)
            }

            showCategoryActionButtons: communityData.amISectionAdmin
            showPopupMenu: communityData.amISectionAdmin && communityData.canManageUsers

            onChatItemUnmuted: root.communitySectionModule.unmuteChat(id)
            onChatItemReordered: function(categoryId, chatId, to) {
                root.store.reorderCommunityChat(categoryId, chatId, to);
            }
            onChatListCategoryReordered: root.store.reorderCommunityCategories(categoryId, to)

            onCategoryAddButtonClicked: Global.openPopup(createChannelPopup, {
                categoryId: id
            })

            popupMenu: StatusMenu {
                StatusAction {
                    text: qsTr("Create channel")
                    icon.name: "channel"
                    enabled: communityData.amISectionAdmin
                    onTriggered: Global.openPopup(createChannelPopup)
                }

                StatusAction {
                    text: qsTr("Create category")
                    icon.name: "channel-category"
                    enabled: communityData.amISectionAdmin
                    onTriggered: Global.openPopup(createCategoryPopup)
                }

                StatusMenuSeparator {}

                StatusAction {
                    text: qsTr("Invite people")
                    icon.name: "share-ios"
                    enabled: communityData.canManageUsers
                    onTriggered: {
                        Global.openInviteFriendsToCommunityPopup(root.communityData,
                                                                 root.communitySectionModule,
                                                                 null)
                    }
                }
            }

            categoryPopupMenu: StatusMenu {
                id: contextMenuCategory
                property var categoryItem

                MuteChatMenuItem {
                    enabled: !!categoryItem && !categoryItem.muted
                    title: qsTr("Mute category")
                    onMuteTriggered: {
                        root.communitySectionModule.muteCategory(categoryItem.itemId, interval)
                        contextMenuCategory.close()
                    }
                }

                StatusAction {
                    enabled: !!categoryItem && categoryItem.muted
                    text: qsTr("Unmute category")
                    icon.name: "notification"
                    onTriggered: {
                        root.communitySectionModule.unmuteCategory(categoryItem.itemId)
                    }
                }

                StatusAction {
                    objectName: "editCategoryMenuItem"
                    enabled: communityData.amISectionAdmin
                    text: qsTr("Edit Category")
                    icon.name: "edit"
                    onTriggered: {
                       Global.openPopup(createCategoryPopup, {
                           isEdit: true,
                           channels: [],
                           categoryId: categoryItem.itemId,
                           categoryName: categoryItem.name
                       })
                    }
                }

                StatusMenuSeparator {
                    visible: communityData.amISectionAdmin
                }

                StatusAction {
                    objectName: "deleteCategoryMenuItem"
                    enabled: communityData.amISectionAdmin
                    text: qsTr("Delete Category")
                    icon.name: "delete"
                    type: StatusAction.Type.Danger
                    onTriggered: {
                        Global.openPopup(deleteCategoryConfirmationDialogComponent, {
                            "header.title": qsTr("Delete '%1' category").arg(categoryItem.name),
                            confirmationText: qsTr("Are you sure you want to delete '%1' category? Channels inside the category won't be deleted.")
                                .arg(categoryItem.name),
                            categoryId: categoryItem.itemId
                        })
                    }
                }
            }

            chatListPopupMenu: ChatContextMenuView {
                id: chatContextMenuView
                emojiPopup: root.emojiPopup

                // TODO pass the chatModel in its entirety instead of fetching the JSOn using just the id
                openHandler: function (id) {
                    try {
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
                        chatIcon = obj.icon
                        chatEmoji = obj.emoji
                        chatColor = obj.color
                        chatType = obj.type
                        chatMuted = obj.muted
                        channelPosition = obj.position
                        chatCategoryId = obj.categoryId
                    } catch (e) {
                        console.error("error parsing chat item json object, id: ", id, " error: ", e)
                        close()
                        return
                    }
                }

                onMuteChat: {
                    root.communitySectionModule.muteChat(chatId, interval)
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
            width: scrollView.availableWidth
            anchors.top: communityChatListAndCategories.bottom
            anchors.topMargin: Style.current.padding
            spacing: Style.current.bigPadding

            Loader {
                active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityWelcomeBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityWelcomeBanners.includes(communityData.id))
                width: parent.width
                height: item.height
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
                active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners.includes(communityData.id))
                width: parent.width
                height: item.height
                sourceComponent: Component {
                        CommunityChannelsAndCategoriesBannerPanel {
                            id: channelsAndCategoriesBanner
                            communityId: communityData.id
                            onAddMembersClicked: {
                                Global.openPopup(createChannelPopup);
                            }
                            onAddCategoriesClicked: {
                                Global.openPopup(createCategoryPopup);
                            }
                        }
                }
            } // Loader

            Loader {
                active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityBackUpBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityBackUpBanners.includes(communityData.id))
                width: parent.width
                height: item.height
                sourceComponent: Component {
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
                }
            } // Loader
        } // Column

        background: Item {
            TapHandler {
                enabled: communityData.amISectionAdmin
                acceptedButtons: Qt.RightButton
                onTapped: {
                    adminPopupMenu.showInviteButton = true
                    adminPopupMenu.x = eventPoint.position.x + 4
                    adminPopupMenu.y = eventPoint.position.y + 4
                    adminPopupMenu.open()
                }
            }
        }
    } // ScrollView

    Loader {
        id: createChatOrCommunity
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: active ? Style.current.padding : 0
        active: communityData.amISectionAdmin
        sourceComponent: Component {
            StatusBaseText {
                id: createChannelOrCategoryBtn
                objectName: "createChannelOrCategoryBtn"
                color: Theme.palette.baseColor1
                height: visible ? implicitHeight : 0
                text: qsTr("Create channel or category")
                font.underline: true
                font.pixelSize: 13
                textFormat: Text.RichText

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        adminPopupMenu.showInviteButton = false
                        adminPopupMenu.popup()
                        adminPopupMenu.y = Qt.binding(() => root.height - adminPopupMenu.height
                            - createChannelOrCategoryBtn.height - 20)
                    }
                }
            }
        }
    }

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
            confirmButtonObjectName: "confirmDeleteCategoryButton"
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
        title: qsTr("Error deleting the category")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
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
