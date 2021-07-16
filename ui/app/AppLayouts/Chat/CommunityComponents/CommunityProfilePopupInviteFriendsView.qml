import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Column {
    id: root

    property string headerTitle: ""

    property var community
    property alias contactListSearch: contactFieldAndList

    function sendInvites(pubKeys) {
        const error = chatsModel.communities.inviteUsersToCommunityById(root.community.id, JSON.stringify(pubKeys))
        if (error) {
            console.error('Error inviting', error)
            contactFieldAndList.validationError = error
            return
        }
        contactFieldAndList.successMessage = qsTr("Invite successfully sent")
    }

    StatusDescriptionListItem {
        title: qsTr("Share community")
        subTitle: `${Constants.communityLinkPrefix}${root.community.id.substring(0, 4)}...${root.community.id.substring(root.community.id.length -2)}`
        tooltip.text: qsTr("Copy to clipboard")
        icon.name: "copy"
        iconButton.onClicked: {
            let link = `${Constants.communityLinkPrefix}${root.community.id}`
            chatsModel.copyToClipboard(link)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }

    StatusModalDivider {
        bottomPadding: 16
    }

    ContactsListAndSearch {
        id: contactFieldAndList
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 32
        showCheckbox: true
        hideCommunityMembers: true
    }
}
