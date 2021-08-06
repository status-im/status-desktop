import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"
import "./CommunityComponents"


Item {
    // TODO unhardcode
    property int chatGroupsListViewCount: communityChatListAndCategories.chatList.count
    property Component pinnedMessagesPopupComponent

    id: root

    Layout.fillHeight: true
    width: 304

    StatusChatInfoToolBar {
        id: communityHeader
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        chatInfoButton.title: chatsModel.communities.activeCommunity.name
        chatInfoButton.subTitle: chatsModel.communities.activeCommunity.nbMembers === 1 ? 
            //% "1 Member"
            qsTrId("1-member") : 
            //% "%1 Members"
            qsTrId("-1-members").arg(chatsModel.communities.activeCommunity.nbMembers)
        chatInfoButton.image.source: chatsModel.communities.activeCommunity.thumbnailImage
        chatInfoButton.icon.color: chatsModel.communities.activeCommunity.communityColor
        menuButton.visible: chatsModel.communities.activeCommunity.admin && chatsModel.communities.activeCommunity.canManageUsers
        chatInfoButton.onClicked: openPopup(communityProfilePopup, {
            community: chatsModel.communities.activeCommunity
        })

        popupMenu: StatusPopupMenu {
            StatusMenuItem {
                //% "Create channel"
                text: qsTrId("create-channel")
                icon.name: "channel"
                enabled: chatsModel.communities.activeCommunity.admin
                onTriggered: openPopup(createChannelPopup, {communityId: chatsModel.communities.activeCommunity.id})
            }

            StatusMenuItem {
                //% "Create category"
                text: qsTrId("create-category")
                icon.name: "channel-category"
                enabled: chatsModel.communities.activeCommunity.admin
                onTriggered: openPopup(createCategoryPopup, {communityId: chatsModel.communities.activeCommunity.id})
            }

           StatusMenuSeparator {}

            StatusMenuItem {
                //% "Invite people"
                text: qsTrId("invite-people")
                icon.name: "share-ios"
                enabled: chatsModel.communities.activeCommunity.canManageUsers
                onTriggered: openPopup(inviteFriendsToCommunityPopup, {
                    community: chatsModel.communities.activeCommunity
                })
            }
        }
    }
    Loader {
        id: membershipRequests

        property int nbRequests: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests

        anchors.top: communityHeader.bottom
        anchors.topMargin: active ? 8 : 0
        anchors.horizontalCenter: parent.horizontalCenter

        active: chatsModel.communities.activeCommunity.admin && nbRequests > 0
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
              
            chatList.model: chatsModel.communities.activeCommunity.chats

            categoryList.model: chatsModel.communities.activeCommunity.categories

            showCategoryActionButtons: chatsModel.communities.activeCommunity.admin
            showPopupMenu: chatsModel.communities.activeCommunity.admin && chatsModel.communities.activeCommunity.canManageUsers
            selectedChatId: chatsModel.channelView.activeChannel.id

            onChatItemSelected: chatsModel.channelView.setActiveChannel(id)
            onChatItemUnmuted: chatsModel.channelView.unmuteChatItem(id)
            onCategoryAddButtonClicked: openPopup(createChannelPopup, {
                communityId: chatsModel.communities.activeCommunity.id,
                categoryId: id
            })

            onReorderChat: function (categoryId, chatId, from, to) {
                chatsModel.communities.reorderCommunityChannel(chatsModel.communities.activeCommunity.id, categoryId, chatId, to);
            }

            popupMenu: StatusPopupMenu {
                StatusMenuItem {
                    //% "Create channel"
                    text: qsTrId("create-channel")
                    icon.name: "channel"
                    enabled: chatsModel.communities.activeCommunity.admin
                    onTriggered: openPopup(createChannelPopup, {communityId: chatsModel.communities.activeCommunity.id})
                }

                StatusMenuItem {
                    //% "Create category"
                    text: qsTrId("create-category")
                    icon.name: "channel-category"
                    enabled: chatsModel.communities.activeCommunity.admin
                    onTriggered: openPopup(createCategoryPopup, {communityId: chatsModel.communities.activeCommunity.id})
                }

                StatusMenuSeparator {}

                StatusMenuItem {
                    //% "Invite people"
                    text: qsTrId("invite-people")
                    icon.name: "share-ios"
                    enabled: chatsModel.communities.activeCommunity.canManageUsers
                    onTriggered: openPopup(inviteFriendsToCommunityPopup, {
                        community: chatsModel.communities.activeCommunity
                    })
                }
            }

            categoryPopupMenu: StatusPopupMenu {

                property var categoryItem

                openHandler: function (id) {
                    categoryItem = chatsModel.communities.activeCommunity.getCommunityCategoryItemById(id)
                }

                StatusMenuItem { 
                    enabled: chatsModel.communities.activeCommunity.admin
                    //% "Edit Category"
                    text: qsTrId("edit-category")
                    icon.name: "edit"
                    onTriggered: {
                        openPopup(createCategoryPopup, {
                            communityId: chatsModel.communities.activeCommunity.id,
                            isEdit: true,
                            categoryId: categoryItem.id,
                            categoryName: categoryItem.name
                        })
                    }
                }

                StatusMenuSeparator {
                    visible: chatsModel.communities.activeCommunity.admin
                }

                StatusMenuItem {
                    enabled: chatsModel.communities.activeCommunity.admin
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

            chatListPopupMenu: ChatContextMenu {
                openHandler: function (id) {
                    chatItem = chatsModel.channelView.getChatItemById(id)
                }
            }
        }

        Loader {
            id: emptyViewAndSuggestionsLoader
            active: chatsModel.communities.activeCommunity.admin && !appSettings.hiddenCommunityWelcomeBanners.includes(chatsModel.communities.activeCommunity.id)
            width: parent.width
            height: active ? item.height : 0
            anchors.top: communityChatListAndCategories.bottom
            anchors.topMargin: active ? Style.current.padding : 0
            sourceComponent: Component {
                CommunityWelcomeBanner {}
            }
        }

        Loader {
            id: backUpBannerLoader
            active: chatsModel.communities.activeCommunity.admin && !appSettings.hiddenCommunityBackUpBanners.includes(chatsModel.communities.activeCommunity.id)
            width: parent.width
            height: active ? item.height : 0
            anchors.top: emptyViewAndSuggestionsLoader.bottom
            anchors.topMargin: active ? Style.current.padding : 0
            sourceComponent: Component {
                Item {
                    width: parent.width
                    height: backupBanner.height

                    BackUpCommuntyBanner {
                        id: backupBanner
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
            height: 216
            showCancelButton: true
            onClosed: {
                destroy()
            }
            onCancelButtonClicked: {
                close();
            }
            onConfirmButtonClicked: function(){
                const error = chatsModel.communities.deleteCommunityCategory(chatsModel.communities.activeCommunity.id, categoryId)
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
