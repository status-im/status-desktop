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

    property var store
    // TODO unhardcode
    property int chatGroupsListViewCount: communityChatListAndCategories.chatList.count
    property Component pinnedMessagesPopupComponent

    StatusChatInfoToolBar {
        id: communityHeader
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        chatInfoButton.title: root.store.chatsModelInst.communities.activeCommunity.name
        chatInfoButton.subTitle: root.store.chatsModelInst.communities.activeCommunity.nbMembers === 1 ?
            //% "1 Member"
            qsTrId("1-member") : 
            //% "%1 Members"
            qsTrId("-1-members").arg(root.store.chatsModelInst.communities.activeCommunity.nbMembers)
        chatInfoButton.image.source: root.store.chatsModelInst.communities.activeCommunity.thumbnailImage
        chatInfoButton.icon.color: root.store.chatsModelInst.communities.activeCommunity.communityColor
        menuButton.visible: root.store.chatsModelInst.communities.activeCommunity.admin && root.store.chatsModelInst.communities.activeCommunity.canManageUsers
        chatInfoButton.onClicked: openPopup(communityProfilePopup, {
            store: root.store,
            community: root.store.chatsModelInst.communities.activeCommunity
        })

        popupMenu: StatusPopupMenu {
            StatusMenuItem {
                //% "Create channel"
                text: qsTrId("create-channel")
                icon.name: "channel"
                enabled: root.store.chatsModelInst.communities.activeCommunity.admin
                onTriggered: openPopup(createChannelPopup, {communityId: chatsModel.communities.activeCommunity.id})
            }

            StatusMenuItem {
                //% "Create category"
                text: qsTrId("create-category")
                icon.name: "channel-category"
                enabled: root.store.chatsModelInst.communities.activeCommunity.admin
                onTriggered: openPopup(createCategoryPopup, {communityId: chatsModel.communities.activeCommunity.id})
            }

           StatusMenuSeparator {}

            StatusMenuItem {
                //% "Invite people"
                text: qsTrId("invite-people")
                icon.name: "share-ios"
                enabled: root.store.chatsModelInst.communities.activeCommunity.canManageUsers
                onTriggered: openPopup(inviteFriendsToCommunityPopup, {
                    community: root.store.chatsModelInst.communities.activeCommunity
                })
            }
        }
    }
    Loader {
        id: membershipRequests

        property int nbRequests: root.store.chatsModelInst.communities.activeCommunity.communityMembershipRequests.nbRequests

        anchors.top: communityHeader.bottom
        anchors.topMargin: active ? 8 : 0
        anchors.horizontalCenter: parent.horizontalCenter

        active: root.store.chatsModelInst.communities.activeCommunity.admin && nbRequests > 0
        height: nbRequests > 0 ? 64 : 0
        sourceComponent: Component {
            StatusContactRequestsIndicatorListItem {
                //% "Membership requests"
                title: qsTrId("membership-requests")
                requestsCount: membershipRequests.nbRequests
                sensor.onClicked: openPopup(membershipRequestPopup)
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
              
            draggableItems: root.store.chatsModelInst.communities.activeCommunity.admin
            draggableCategories: root.store.chatsModelInst.communities.activeCommunity.admin
            chatList.model: root.store.chatsModelInst.communities.activeCommunity.chats

            categoryList.model: root.store.chatsModelInst.communities.activeCommunity.categories

            showCategoryActionButtons: root.store.chatsModelInst.communities.activeCommunity.admin
            showPopupMenu: root.store.chatsModelInst.communities.activeCommunity.admin && chatsModel.communities.activeCommunity.canManageUsers
            selectedChatId: root.store.chatsModelInst.channelView.activeChannel.id

            onChatItemSelected: root.store.chatsModelInst.channelView.setActiveChannel(id)
            onChatItemUnmuted: root.store.chatsModelInst.channelView.unmuteChatItem(id)
            onChatItemReordered: function (categoryId, id, from, to) {
                root.store.chatsModelInst.communities.reorderCommunityChannel(chatsModel.communities.activeCommunity.id, categoryId, id, to);
            }
            onChatListCategoryReordered: function (categoryId, from, to) {
                root.store.chatsModelInst.communities.reorderCommunityCategories(chatsModel.communities.activeCommunity.id, categoryId, to);
            }

            onCategoryAddButtonClicked: openPopup(createChannelPopup, {
                communityId: root.store.chatsModelInst.communities.activeCommunity.id,
                categoryId: id
            })

            popupMenu: StatusPopupMenu {
                StatusMenuItem {
                    //% "Create channel"
                    text: qsTrId("create-channel")
                    icon.name: "channel"
                    enabled: chatsModel.communities.activeCommunity.admin
                    onTriggered: openPopup(createChannelPopup, {communityId: root.store.chatsModelInst.communities.activeCommunity.id})
                }

                StatusMenuItem {
                    //% "Create category"
                    text: qsTrId("create-category")
                    icon.name: "channel-category"
                    enabled: root.store.chatsModelInst.communities.activeCommunity.admin
                    onTriggered: openPopup(createCategoryPopup, {communityId: root.store.chatsModelInst.communities.activeCommunity.id})
                }

                StatusMenuSeparator {}

                StatusMenuItem {
                    //% "Invite people"
                    text: qsTrId("invite-people")
                    icon.name: "share-ios"
                    enabled: root.store.chatsModelInst.communities.activeCommunity.canManageUsers
                    onTriggered: openPopup(inviteFriendsToCommunityPopup, {
                        community: root.store.chatsModelInst.communities.activeCommunity
                    })
                }
            }

            categoryPopupMenu: StatusPopupMenu {

                property var categoryItem

                openHandler: function (id) {
                    categoryItem = root.store.chatsModelInst.communities.activeCommunity.getCommunityCategoryItemById(id)
                }

                StatusMenuItem { 
                    enabled: root.store.chatsModelInst.communities.activeCommunity.admin
                    //% "Edit Category"
                    text: qsTrId("edit-category")
                    icon.name: "edit"
                    onTriggered: {
                        openPopup(createCategoryPopup, {
                            communityId: root.store.chatsModelInst.communities.activeCommunity.id,
                            isEdit: true,
                            categoryId: categoryItem.id,
                            categoryName: categoryItem.name
                        })
                    }
                }

                StatusMenuSeparator {
                    visible: root.store.chatsModelInst.communities.activeCommunity.admin
                }

                StatusMenuItem {
                    enabled: root.store.chatsModelInst.communities.activeCommunity.admin
                    //% "Delete Category"
                    text: qsTrId("delete-category")
                    icon.name: "delete"
                    type: StatusMenuItem.Type.Danger
                    onTriggered: {
                        openPopup(deleteCategoryConfirmationDialogComponent, {
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
                store: root.store
                openHandler: function (id) {
                    chatItem = root.store.chatsModelInst.channelView.getChatItemById(id)
                }
            }
        }

        Loader {
            id: emptyViewAndSuggestionsLoader
            active: root.store.chatsModelInst.communities.activeCommunity.admin &&
                     (!localAccountSensitiveSettings.hiddenCommunityWelcomeBanners ||
                      !localAccountSensitiveSettings.hiddenCommunityWelcomeBanners.includes(root.store.chatsModelInst.communities.activeCommunity.id))
            width: parent.width
            height: active ? item.height : 0
            anchors.top: communityChatListAndCategories.bottom
            anchors.topMargin: active ? Style.current.padding : 0
            sourceComponent: Component {
                CommunityWelcomeBannerPanel {
                    activeCommunity: store.activeCommunity
                    store: root.store
                }
            }
        }

        Loader {
            id: backUpBannerLoader
            active: root.store.chatsModelInst.communities.activeCommunity.admin &&
                        (!localAccountSensitiveSettings.hiddenCommunityBackUpBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityBackUpBanners.includes(root.store.chatsModelInst.communities.activeCommunity.id))
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
                        activeCommunity: store.activeCommunity
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
            store: root.store
            pinnedMessagesPopupComponent: root.pinnedMessagesPopupComponent
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
                const error = root.store.chatsModelInst.communities.deleteCommunityCategory(root.store.chatsModelInst.communities.activeCommunity.id, categoryId)
                if (error) {
                    creatingError.text = error
                    return creatingError.open()
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
            onClosed: {
                destroy()
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
