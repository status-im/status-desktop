import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"
import "./"

ListView {
    id: communityListView
    spacing: 12
    height: contentHeight
    visible: height > 10
    width:parent.width
    interactive: false
    verticalLayoutDirection: ListView.BottomToTop

    model: chatsModel.communities.joinedCommunities
    delegate: CommunityButton {
        communityId: model.id
        name: model.name
        image: model.thumbnailImage
        unviewedMessagesCount: model.unviewedMessagesCount
        iconColor: model.communityColor || Style.current.blue
        useLetterIdenticon: model.thumbnailImage === ""
    }

    PopupMenu {
        property string communityId

        onAboutToShow: {
            chatsModel.communities.setObservedCommunity(commnunityMenu.communityId)
        }

        id: commnunityMenu
        Action {
            text: qsTr("Invite People")
            enabled: chatsModel.communities.observedCommunity.canManageUsers
            icon.source: "../../../img/export.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: openPopup(inviteFriendsToCommunityPopup, {communityId: commnunityMenu.communityId})
        }
        Action {
            text: qsTr("View Community")
            icon.source: "../../../img/group.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: openPopup(communityMembersPopup, {community: chatsModel.communities.observedCommunity})
        }
        Separator  {
            height: 10
        }
        Action {
            text: qsTr("Edit Community")
            // TODO reenable this option once the edit feature is done
            enabled: false//chatsModel.communities.observedCommunity.admin
            icon.source: "../../../img/edit.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: openPopup(editCommunityPopup, {community: chatsModel.communities.observedCommunity})
        }
        Action {
            text: qsTr("Leave Community")
            icon.source: "../../../img/arrow-left.svg"
            icon.width: 12
            icon.height: 9
            onTriggered: {
                chatsModel.communities.leaveCommunity(commnunityMenu.communityId)
            }
        }
    }
}
