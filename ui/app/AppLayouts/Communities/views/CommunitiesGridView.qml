import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Communities.controls 1.0

StatusScrollView {
    id: root

    property var model
    property bool searchLayout: false

    property var assetsModel
    property var collectiblesModel

    readonly property bool isEmpty: !featuredRepeater.count && !popularRepeater.count

    signal cardClicked(string communityId)

    clip: false

    QtObject {
        id: d

        // values from the design
        readonly property int scrollViewTopMargin: 20
        readonly property int subtitlePixelSize: 17
    }

    SortFilterProxyModel {
        id: featuredModel

        sourceModel: root.model

        filters: ValueFilter {
            roleName: "featured"
            value: true
        }
    }

    SortFilterProxyModel {
        id: popularModel

        sourceModel: root.model

        filters: ValueFilter {
            roleName: "featured"
            value: false
        }
    }

    Component {
        id: communityCardDelegate

        StatusCommunityCard {
            id: card

            readonly property string tags: model.tags
            readonly property var permissionsList: model.permissionsModel
            readonly property bool requirementsMet: !!model.allTokenRequirementsMet ? model.allTokenRequirementsMet : false

            JSONListModel {
                id: tagsJson
                json: tags
            }

            communityId: model.id
            loaded: model.available
            logo: model.icon
            banner: model.banner
            communityColor: model.color
            name: model.name
            description: model.description
            members: model.members
            activeUsers: model.activeMembers
            popularity: model.popularity
            categories: tagsJson.model


            // Community restrictions
            rigthHeaderComponent: PermissionsRow {
                visible: !!card.permissionsList && card.permissionsList.count > 0
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: card.permissionsList
                requirementsMet: card.requirementsMet
            }

            onClicked: root.cardClicked(communityId)
        }
    }

    ColumnLayout {
        id: contentColumn

        StatusBaseText {
            id: featuredLabel
            visible: !root.searchLayout && featuredRepeater.count
            Layout.topMargin: d.scrollViewTopMargin
            //: Featured communities
            text: qsTr("Featured")
            font.weight: Font.Bold
            font.pixelSize: d.subtitlePixelSize
            color: Theme.palette.directColor1
        }

        GridLayout {
            Layout.topMargin: root.searchLayout
                              ? featuredLabel.height + contentColumn.spacing + featuredLabel.Layout.topMargin
                              : 0
            columns: 3
            columnSpacing: Style.current.padding
            rowSpacing: Style.current.padding
            visible: featuredRepeater.count

            Repeater {
                id: featuredRepeater
                model: root.searchLayout ? root.model : featuredModel
                delegate: communityCardDelegate
            }
        }

        StatusBaseText {
            visible: !root.searchLayout && popularRepeater.count
            Layout.topMargin: 20
            //: All communities
            text: qsTr("All")
            font.weight: Font.Bold
            font.pixelSize: d.subtitlePixelSize
            color: Theme.palette.directColor1
        }

        GridLayout {
            visible: !root.searchLayout
            columns: 3
            columnSpacing: Style.current.padding
            rowSpacing: Style.current.padding

            Repeater {
                id: popularRepeater
                model: popularModel
                delegate: communityCardDelegate
            }
        }
    }
}
