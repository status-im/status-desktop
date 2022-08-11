import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.popups 1.0

import "stores"
import "popups"
import "../../AppLayouts/Chat/panels/communities" // TODO correct import? or move somewhere else?

StatusScrollView {
    id: root
    objectName: "communitiesPortalLayout"

    property CommunitiesStore communitiesStore: CommunitiesStore {}
    property var importCommunitiesPopup: importCommunitiesPopupComponent
    property var createCommunitiesPopup: createCommunitiesPopupComponent

    QtObject {
        id: d

        property ListModel tagsModel: root.communitiesStore.tagsModel

        property string searchText: ""
        property int layoutVMargin: 70
        property int layoutHMargin: 64
        property int titlePixelSize: 28
        property int subtitlePixelSize: 17

        function navigateToCommunity(communityId) {
            root.communitiesStore.setActiveCommunity(communityId)
        }
    }

    contentHeight: column.height + d.layoutVMargin
    contentWidth: column.width + d.layoutHMargin

    ColumnLayout {
        id: column
        width: parent.width
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
            implicitWidth: parent.width
            implicitHeight: 38
            spacing: Style.current.bigPadding

            StatusInput {
                id: searcher
                implicitWidth: 327
                Layout.leftMargin: d.layoutHMargin
                Layout.alignment: Qt.AlignVCenter
                enabled: false // Out of scope
                placeholderText: qsTr("Search")
                input.icon.name: "search"
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                minimumHeight: 36
                maximumHeight: 36
                text: d.searchText
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
                Layout.fillHeight: true
                text: qsTr("Import using key")
                onClicked: Global.openPopup(importCommunitiesPopupComponent)
            }

            StatusButton {
                id: createBtn
                objectName: "createCommunityButton"
                Layout.fillHeight: true
                text: qsTr("Create New Community")
                onClicked: {
                    if (localAccountSensitiveSettings.isDiscordImportToolEnabled) {
                      Global.openPopup(chooseCommunityCreationTypePopupComponent)
                    } else {
                      Global.openPopup(createCommunitiesPopupComponent)
                    }
                }
            }

            // TODO temp until we have the progress banner
            StatusButton {
                Layout.fillHeight: true
                text: "Show Discord Import Progress"
                visible: localAccountSensitiveSettings.isDiscordImportToolEnabled
                onClicked: Global.openPopup(discordImportProgressDialog)
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
                model: root.communitiesStore.curatedCommunitiesModel
                delegate: StatusCommunityCard {
                    visible: model.featured
                    locale: communitiesStore.locale
                    communityId: model.id
                    loaded: model.available
                    logo: model.icon
                    name: model.name
                    description: model.description
                    members: model.members
                    popularity: model.popularity
                    // <out of scope> categories:  model.categories

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
            columnSpacing: Style.current.padding
            rowSpacing: Style.current.padding

            Repeater {
                model: root.communitiesStore.curatedCommunitiesModel
                delegate: StatusCommunityCard {
                    visible: !model.featured
                    locale: communitiesStore.locale
                    communityId: model.id
                    loaded: model.available
                    logo: model.icon
                    name: model.name
                    description: model.description
                    members: model.members
                    popularity: model.popularity
                    // <out of scope> categories:  model.categories

                    onClicked: { d.navigateToCommunity(communityId) }
                }
            }
        }
    }

    Component {
        id: importCommunitiesPopupComponent
        ImportCommunityPopup {
            anchors.centerIn: parent
            store: root.communitiesStore
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCommunitiesPopupComponent
        CreateCommunityPopup {
            anchors.centerIn: parent
            store: root.communitiesStore
        }
    }

    Component {
        id: chooseCommunityCreationTypePopupComponent
        StatusDialog {
            id: chooseCommunityCreationTypePopup
            title: qsTr("Create new community")
            horizontalPadding: 40
            verticalPadding: 60
            footer: null
            onClosed: destroy()

            contentItem: RowLayout {
                spacing: 20
                CommunityBanner {
                    text: qsTr("Create a new Status community")
                    buttonText: qsTr("Create new")
                    icon.name: "favourite"
                    onButtonClicked: {
                        chooseCommunityCreationTypePopup.close()
                        Global.openPopup(createCommunitiesPopupComponent)
                    }
                }
                CommunityBanner {
                    text: qsTr("Import existing Discord community into Status")
                    buttonText: qsTr("Import existing")
                    icon.name: "download"
                    onButtonClicked: {
                        chooseCommunityCreationTypePopup.close()
                        Global.openPopup(createCommunitiesPopupComponent, {isDiscordImport: true})
                    }
                }
            }
        }
    }

    Component {
        id: discordImportProgressDialog
        DiscordImportProgressDialog {
            store: root.communitiesStore
        }
    }
}
