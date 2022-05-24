import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import "stores"

ScrollView {
    id: root

    property CommunitiesStore communitiesStore: CommunitiesStore {}        

    QtObject {
        id: d

        property ListModel featuredCommunitiesModel: root.communitiesStore.featuredCommunitiesModel
        property ListModel popularCommunitiesModel: root.communitiesStore.popularCommunitiesModel
        property ListModel tagsModel: root.communitiesStore.tagsModel

        property string searchText: ""
        property int layoutVMargin: 70
        property int layoutHMargin: 64
        property int titlePixelSize: 28
        property int subtitlePixelSize: 17

        function navigateToCommunity(communityId) {
            console.warn("TODO: Navigate to community ID: " + communityId)
        }
    }

    contentHeight: column.height + d.layoutVMargin
    contentWidth: column.width + d.layoutHMargin
    clip: true

    ColumnLayout {
        id: column
        spacing: 18

        StatusBaseText {
            Layout.topMargin: d.layoutVMargin
            Layout.leftMargin: d.layoutHMargin
            text: qsTr("Find community")
            font.weight: Font.Bold
            font.pixelSize: d.titlePixelSize
            color: Theme.palette.directColor1
        }

        RowLayout {
            width: 230/*Card Width by design*/ * featuredGrid.columns  + 2 * featuredGrid.rowSpacing
            spacing: 24

            StatusBaseInput {
                id: searcher
                enabled: false // Out of scope
                Layout.leftMargin: d.layoutHMargin
                height: 36 // by design
                width: 351 // by design
                placeholderText: qsTr("Search")
                text: d.searchText
                icon.name: "search"

                onTextChanged: {
                    console.warn("TODO: Community Cards searcher algorithm.")
                    // 1. Filter Community Cards by title, description or tags category.
                    // 2. Once some filter is applyed, update main tags row only showing the tags that are part of the categories of the filtered Community Cards.
                }
            }

            // Just a row filler to fit design
            Item { Layout.fillWidth: true }

            StatusButton {
                id: importBtn
                text: qsTr("Import Community")
                enabled: false // Out of scope
            }

            StatusButton {
                id: createBtn
                text: qsTr("Creat New Community")
                enabled: false // Out of scope
            }
        }

        Row {
            width: 1234
            Text {
                text: "CURATED COMMUNITY LIST ========="
            }
            Repeater {
                model: root.communitiesStore.curatedCommunitiesModel
                delegate:  Text {
                    text: model.name + " " + model.description + " " + model.icon + " " + model.available
                }
            }
        }

        // Tags definition - Now hidden - Out of scope
        // TODO: Replace by `StatusListItemTagRow`
        Row {
            visible: false//d.tagsModel.count > 0 --> out of scope
            Layout.leftMargin: d.layoutHMargin
            Layout.rightMargin: d.layoutHMargin
            width: 1234 // by design
            spacing: Style.current.halfPadding

            Repeater {
                model: d.tagsModel
                delegate: StatusListItemTag {
                    border.color: Theme.palette.baseColor2
                    color: "transparent"
                    height: 32
                    radius: 36
                    closeButtonVisible: false
                    icon.emoji: model.emoji
                    icon.height: 32
                    icon.width: icon.height
                    icon.color: "transparent"
                    icon.isLetterIdenticon: true
                    title: model.name
                    titleText.font.pixelSize: 15
                    titleText.color: Theme.palette.primaryColor1
                }
            }

            // TODO: Add next button
            // ...
        }

        StatusBaseText {
            Layout.leftMargin: d.layoutHMargin
            Layout.topMargin: 20
            text: qsTr("Featured")
            font.weight: Font.Bold
            font.pixelSize: d.subtitlePixelSize
            color: Theme.palette.directColor1
        }

        GridLayout {
            id: featuredGrid
            Layout.leftMargin: d.layoutHMargin
            columns: 3
            columnSpacing: Style.current.padding
            rowSpacing: Style.current.padding

            Repeater {
                model: d.featuredCommunitiesModel
                delegate: StatusCommunityCard {
                    locale: communitiesStore.locale
                    communityId: model.communityId
                    loaded: model.available
                    logo: model.icon
                    name: model.name
                    description: model.description
                    members: model.members
                    popularity: model.popularity
                    // <out of scope> categories:  model.categories

                    onCardSelected: { d.navigateToCommunity(communityId) }
                }
            }
        }

        StatusBaseText {
            Layout.leftMargin: d.layoutHMargin
            Layout.topMargin: 20
            text: qsTr("Popular")
            font.weight: Font.Bold
            font.pixelSize: d.subtitlePixelSize
            color: Theme.palette.directColor1
        }

        GridLayout {
            Layout.leftMargin: d.layoutHMargin
            columns: 3
            columnSpacing: Style.current.padding
            rowSpacing: Style.current.padding

            Repeater {
                model: d.popularCommunitiesModel
                delegate: StatusCommunityCard {
                    locale: communitiesStore.locale
                    communityId: model.communityId
                    loaded: model.available
                    logo: model.icon
                    name: model.name
                    description: model.description
                    members: model.members
                    popularity: model.popularity
                    // <out of scope> categories:  model.categories

                    onCardSelected: { d.navigateToCommunity(communityId) }
                }
            }
        }
    }
}
