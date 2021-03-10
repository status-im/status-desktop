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
    height: childrenRect.height
    visible: height > 10
    width:parent.width
    interactive: false

    model: chatsModel.communities.joinedCommunities
    delegate: CommunityButton {
        communityId: model.id
        name: model.name
        image: model.thumbnailImage
        unviewedMessagesCount: model.unviewedMessagesCount
        iconColor: model.communityColor
        useLetterIdenticon: model.thumbnailImage === ""
    }
}
