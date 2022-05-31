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
    columnSpacing: 16
    rowSpacing: 16

    Repeater {
        model: Models.curatedCommunitiesModel
        delegate: StatusCommunityCard {
            locale: "en"
            communityId: model.communityId
            loaded: model.available
            logo: model.icon
            name: model.name
            description: model.description
            members: model.members
            popularity: model.popularity
            categories: ListModel {
                ListElement { name: "sport"; emoji: "🎾"}
                ListElement { name: "food"; emoji: "🥑"}
                ListElement { name: "privacy"; emoji: "👻"}
            }

            onClicked: { d.navigateToCommunity(communityId) }
        }
    }
}
