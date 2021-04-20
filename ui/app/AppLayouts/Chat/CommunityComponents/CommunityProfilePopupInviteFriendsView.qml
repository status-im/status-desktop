import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: root

    property string headerTitle: ""
    property string headerDescription: ""
    property string headerImageSource: ""

    property alias contactListSearch: contactFieldAndList

    height: 400

    function sendInvites(pubKeys) {
        const error = chatsModel.communities.inviteUsersToCommunityById(popup.communityId, JSON.stringify(pubKeys))
        if (error) {
            console.error('Error inviting', error)
            contactFieldAndList.validationError = error
            return
        }
        contactFieldAndList.successMessage = qsTr("Invite successfully sent")
    }

    TextWithLabel {
        id: shareCommunity
        anchors.top: parent.top
        anchors.topMargin: 0
        //% "Share community"
        label: qsTrId("share-community")
        text: `${Constants.communityLinkPrefix}${communityId.substring(0, 4)}...${communityId.substring(communityId.length -2)}`
        textToCopy: Constants.communityLinkPrefix + communityId
    }

    Separator {
        id: sep
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: shareCommunity.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
    }

    ContactsListAndSearch {
        id: contactFieldAndList
        anchors.top: sep.bottom
        anchors.topMargin: Style.current.smallPadding
        showCheckbox: true
    }
}
