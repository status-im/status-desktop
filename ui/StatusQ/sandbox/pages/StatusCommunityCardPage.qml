import QtQuick 2.0
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1

import "../demoapp/data" 1.0

GridLayout {

    QtObject {
        id: d

        function navigateToCommunity(communityID) {
            console.log("Clicked community: " + communityID)
        }
    }

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    columns: 2
    columnSpacing: 28
    rowSpacing: 28

    Repeater {
        model: Models.curatedCommunitiesModel
        delegate: StatusCommunityCard {
            locale: "en"
            communityId: model.communityId
            loaded: model.available
            logo: model.logo
            banner: model.banner
            name: model.name
            description: model.description
            members: model.members
            activeUsers: model.activeUsers
            popularity: model.popularity
            isPrivate: model.isPrivate
            tokenLogo: model.tokenLogo
            categories: ListModel {
                ListElement { name: "Crypto"; emoji: "🔗"}
                ListElement { name: "Privacy"; emoji: "👻"}
                ListElement { name: "Social"; emoji: "☕"}
            }

            onClicked: { d.navigateToCommunity(communityId) }
        }
    }
}
