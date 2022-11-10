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
import "../popups/community"
import "../panels/communities"

// FIXME: Rework me to use ColumnLayout instead of anchors!!
Item {
    id: root
    objectName: "communityColumnView"
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
    property Component membershipRequestPopup

    signal infoButtonClicked
    signal manageButtonClicked

    MouseArea {
        enabled: communityData.amISectionAdmin
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.RightButton
        onClicked: {
            adminPopupMenu.showInviteButton = true
            adminPopupMenu.x = mouse.x + 4
            adminPopupMenu.y = mouse.y + 4
            adminPopupMenu.open()
        }
    }

    StatusChatInfoButton {
        id: communityHeader
        objectName: "communityHeaderButton"
        readonly property int nbMembers: communityData.members.count
        title: communityData.name
        subTitle: qsTr("%n member(s)", "", nbMembers)
        asset.name: communityData.image
        asset.color: communityData.color
        asset.isImage: true
        onClicked: if (communityData.amISectionAdmin) { root.infoButtonClicked() }
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.halfPadding
        anchors.right: (implicitWidth > parent.width - 50) ? adHocChatButton.left : undefined
        anchors.rightMargin: Style.current.halfPadding
        type: StatusChatInfoButton.Type.OneToOneChat
        hoverEnabled: communityData.amISectionAdmin
    }

    StatusIconTabButton {
        id: adHocChatButton
        icon.name: "edit"
        objectName: "startChatButton"
        icon.color: Theme.palette.directColor1
        anchors.verticalCenter: communityHeader.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        checked: root.store.openCreateChat
        highlighted: root.store.openCreateChat
        onClicked: {
            if (root.store.openCreateChat) {
                Global.closeCreateChatView()
            } else {
                Global.openCreateChatView()
            }
        }

        StatusToolTip {
            text: qsTr("Start chat")
            visible: parent.hovered
            orientation: StatusToolTip.Orientation.Bottom
            y: parent.height + 12
        }
    }

    StatusButton {
        id: joinCommunityButton

        property bool invitationPending: root.store.isCommunityRequestPending(communityData.id)

        anchors.top: communityHeader.bottom
        anchors.topMargin: 8
        anchors.bottomMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter

        visible: !communityData.joined

        text: {
            if (invitationPending) return qsTr("Membership request pending...")
            return root.communityData.access === Constants.communityChatOnRequestAccess ?
                    qsTr("Request to join") : qsTr("Join Community")
        }

        onClicked: {
            communityIntroDialog.open()
        }

        Connections {
            target: root.store.communitiesModuleInst
            onCommunityAccessRequested: function (communityId) {
                if (communityId === communityData.id) {
                    joinCommunityButton.invitationPending = root.store.isCommunityRequestPending(communityData.id)
                }
            }
        }

        CommunityIntroDialog {
            id: communityIntroDialog

            isInvitationPending: joinCommunityButton.invitationPending
            name: communityData.name
            introMessage: communityData.introMessage
            imageSrc: communityData.image
            accessType: communityData.access

            onJoined: root.store.requestToJoinCommunity(communityData.id, root.store.userProfileInst.name)
            onCancelMembershipRequest: {
                root.store.cancelPendingRequest(communityData.id)
                joinCommunityButton.invitationPending = root.store.isCommunityRequestPending(communityData.id)
            }
        }
    }

    Loader {
        id: membershipRequests

        property int nbRequests: root.communityData.pendingRequestsToJoin.count || 0

        anchors.top: joinCommunityButton.visible ? joinCommunityButton.bottom : communityHeader.bottom
        anchors.topMargin: active ? 8 : 0
        anchors.horizontalCenter: parent.horizontalCenter

        active: communityData.amISectionAdmin && nbRequests > 0
        height: nbRequests > 0 ? 64 : 0
        sourceComponent: Component {
            StatusContactRequestsIndicatorListItem {
                title: qsTr("Membership requests")
                requestsCount: membershipRequests.nbRequests
                onClicked: Global.openPopup(root.membershipRequestPopup, {
                    communitySectionModule: root.communitySectionModule
                })
            }
        }
    }

    StatusPopupMenu {
        id: adminPopupMenu
        enabled: communityData.amISectionAdmin

        property bool showInviteButton: false

        onClosed: adminPopupMenu.showInviteButton = false

        StatusMenuItem {
            objectName: "createCommunityChannelBtn"
            text: qsTr("Create channel")
            icon.name: "channel"
            onTriggered: Global.openPopup(createChannelPopup)
        }

        StatusMenuItem {
            objectName: "createCommunityCategoryBtn"
            text: qsTr("Create category")
            icon.name: "channel-category"
            onTriggered: Global.openPopup(createCategoryPopup)
        }

        StatusMenuSeparator {
            visible: invitePeopleBtn.enabled
        }

        StatusMenuItem {
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
        anchors.top: membershipRequests.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: createChatOrCommunity.top
        anchors.horizontalCenter: parent.horizontalCenter

        topPadding: Style.current.padding

        width: parent.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: communityChatListAndCategories.height
                       + bannerColumn.height
                       + Style.current.bigPadding

        StatusChatListAndCategories {
            id: communityChatListAndCategories
            anchors.horizontalCenter: parent.horizontalCenter
            draggableItems: communityData.amISectionAdmin
            draggableCategories: communityData.amISectionAdmin

            model: root.communitySectionModule.model
            highlightItem: !root.store.openCreateChat

            onChatItemSelected: {
                Global.closeCreateChatView()

                if(categoryId === "")
                    root.communitySectionModule.setActiveItem(id, "")
                else
                    root.communitySectionModule.setActiveItem(categoryId, id)
            }

            showCategoryActionButtons: communityData.amISectionAdmin
            showPopupMenu: communityData.amISectionAdmin && communityData.canManageUsers

            onChatItemUnmuted: root.communitySectionModule.unmuteChat(id)
            onChatItemReordered: function(categoryId, chatId, from, to){
                root.store.reorderCommunityChat(categoryId, chatId, to)
            }
            onChatListCategoryReordered: root.store.reorderCommunityCategories(categoryId, to)

            onCategoryAddButtonClicked: Global.openPopup(createChannelPopup, {
                categoryId: id
            })

            popupMenu: StatusPopupMenu {
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
                    onTriggered: {
                        Global.openInviteFriendsToCommunityPopup(root.communityData,
                                                                 root.communitySectionModule,
                                                                 null)
                    }
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
                    text: categoryItem.muted ? qsTr("Unmute category") : qsTr("Mute category")
                    icon.name: "notification"
                    onTriggered: {
                        if (categoryItem.muted) {
                            root.communitySectionModule.unmuteCategory(categoryItem.itemId)
                        } else {
                            root.communitySectionModule.muteCategory(categoryItem.itemId)
                        }
                    }
                }

                StatusMenuItem {
                    objectName: "editCategoryMenuItem"
                    enabled: communityData.amISectionAdmin
                    text: qsTr("Edit Category")
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
                    objectName: "deleteCategoryMenuItem"
                    enabled: communityData.amISectionAdmin
                    text: qsTr("Delete Category")
                    icon.name: "delete"
                    type: StatusMenuItem.Type.Danger
                    onTriggered: {
                        Global.openPopup(deleteCategoryConfirmationDialogComponent, {
                            title: qsTr("Delete %1 category").arg(categoryItem.name),
                            confirmationText: qsTr("Are you sure you want to delete %1 category? Channels inside the category won’t be deleted.")
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
                    chatIcon = obj.icon
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
                height: {
                    // I dont know why, the binding doesn't work well if this isn't here
                    item && item.height
                    return active ? item.height : 0
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
                active: communityData.amISectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners.includes(communityData.id))
                width: parent.width
                height: {
                    // I dont know why, the binding doesn't work well if this isn't here
                    item && item.height
                    return active ? item.height : 0
                }
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
                height: {
                    // I dont know why, the binding doesn't work well if this isn't here
                    item && item.height
                    return active ? item.height : 0
                }
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
    } // ScrollView

    Loader {
        id: createChatOrCommunity
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
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
