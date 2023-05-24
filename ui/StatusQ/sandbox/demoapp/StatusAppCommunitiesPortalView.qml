import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1

import "../demoapp/data" 1.0

StatusSectionLayout {
    id: root

    QtObject {
        id: d

        property ListModel featuredCommunitiesModel: Models.featuredCommunitiesModel
        property ListModel popularCommunitiesModel: Models.curatedCommunitiesModel
        property ListModel tagsModel: Models.tagsModel

        property string searchText: ""
        property int layoutVMargin: 70
        property int layoutHMargin: 64
        property int titlePixelSize: 28
        property int subtitlePixelSize: 17
        property int stylePadding: 16

        function navigateToCommunity(communityId) {
            console.info("Clicked community ID: " + communityId)
        }
    }
    centerPanel: Item {
        anchors.fill: parent
        clip: true

        StatusScrollView {
            anchors.fill: parent

            ColumnLayout {
                id: column
                spacing: 18

                StatusBaseText {
                    text: qsTr("Find community")
                    font.weight: Font.Bold
                    font.pixelSize: d.titlePixelSize
                    color: Theme.palette.directColor1
                }

                // Tags definition - Now hidden - Out of scope
                // TODO: Replace by `StatusListItemTagRow`
                Row {
                    visible: d.tagsModel.count > 0
                    Layout.leftMargin: d.layoutHMargin
                    Layout.rightMargin: d.layoutHMargin
                    width: 1234 // by design
                    spacing: d.stylePadding/2

                    Repeater {
                        model: d.tagsModel
                        delegate: StatusListItemTag {
                            bgColor: "transparent"
                            bgRadius: 36
                            bgBorderColor: Theme.palette.baseColor2
                            height: 32
                            closeButtonVisible: false
                            asset.emoji: model.emoji
                            asset.height: 32
                            asset.width: asset.height
                            asset.color: "transparent"
                            asset.isLetterIdenticon: true
                            title: model.name
                            titleText.font.pixelSize: 15
                            titleText.color: Theme.palette.primaryColor1
                        }
                    }
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
                    columnSpacing: d.stylePadding
                    rowSpacing: d.stylePadding

                    Repeater {
                        model: d.featuredCommunitiesModel
                        delegate: StatusCommunityCard {
                            locale: Qt.locale("es")
                            communityId: model.communityId
                            loaded: model.available
                            logo: model.logo
                            name: model.name
                            description: model.description
                            members: model.members
                            popularity: model.popularity
                            communityColor: model.communityColor
                            categories: ListModel {
                                ListElement { name: "sport"; emoji: "🎾"}
                                ListElement { name: "food"; emoji: "🥑"}
                                ListElement { name: "privacy"; emoji: "👻"}
                            }

                            onClicked: { d.navigateToCommunity(communityId) }
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
                    columnSpacing: d.stylePadding
                    rowSpacing: d.stylePadding

                    Repeater {
                        model: d.popularCommunitiesModel
                        delegate: StatusCommunityCard {
                            locale: Qt.locale("es")
                            communityId: model.communityId
                            loaded: model.available
                            logo: model.logo
                            name: model.name
                            description: model.description
                            members: model.members
                            activeUsers: model.activeUsers
                            popularity: model.popularity
                            tokenLogo: model.tokenLogo
                            banner: model.banner

                            onClicked: { d.navigateToCommunity(communityId) }
                        }
                    }
                }
            }
        }
    }
}
