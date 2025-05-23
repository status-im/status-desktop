import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    Logs { id: logs }

    ListModel {
        id: categoriesModel
        ListElement { name: "gaming"; emoji: "🎮"; selected: false }
        ListElement { name: "art"; emoji: "🖼️️"; selected: false }
        ListElement { name: "crypto"; emoji: "💸"; selected: true }
        ListElement { name: "nsfw"; emoji: "🍆"; selected: false }
        ListElement { name: "markets"; emoji: "💎"; selected: false }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusCommunityCard {
            anchors.centerIn: parent
            cardSize: ctrlSize.checked ? StatusCommunityCard.Size.Big : StatusCommunityCard.Size.Small
            communityId: "community_id"
            name: infoEditor.name
            description: infoEditor.description
            members: infoEditor.membersCount
            activeUsers: members/2
            //popularity: 4 // not visualized?
            banner: infoEditor.banner
            asset.source: infoEditor.image
            asset.isImage: true
            communityColor: infoEditor.color
            loaded: !ctrlLoading.checked

            Binding on categories {
                value: categoriesModel
                when: ctrlCategories.checked
            }

            onClicked: logs.logEvent("StatusCommunityCard::onClicked", ["communityId"], arguments)
            onRightClicked: logs.logEvent("StatusCommunityCard::onRightClicked", ["communityId"], arguments)
        }
    }

    LogsAndControlsPanel {
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        CommunityInfoEditor {
            id: infoEditor
            colorVisible: true
            adminControlsEnabled: false

            Switch {
                id: ctrlSize
                text: "Big card"
                checked: true
            }

            Switch {
                id: ctrlCategories
                text: "Categories/tags"
                checked: true
            }

            Switch {
                id: ctrlLoading
                text: "Loading"
                checked: false
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416159
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416160
