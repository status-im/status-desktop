import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import SortFilterProxyModel 0.2

StatusScrollView {
    id: root

    property var locale
    property var model
    property bool searchLayout: false

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
            locale: root.locale
            communityId: model.communityId
            loaded: model.available
            logo: model.icon
            name: model.name
            description: model.description
            members: model.members
            popularity: model.popularity
            // <out of scope> categories:  model.categories

            onClicked: root.cardClicked(communityId)
        }
    }

    ColumnLayout {
        id: contentColumn

        StatusBaseText {
            id: featuredLabel
            visible: !root.searchLayout
            Layout.topMargin: d.scrollViewTopMargin
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

            Repeater {
                model: root.searchLayout ? root.model : featuredModel
                delegate: communityCardDelegate
            }
        }

        StatusBaseText {
            visible: !root.searchLayout
            Layout.topMargin: 20
            text: qsTr("Popular")
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
                model: popularModel
                delegate: communityCardDelegate
            }
        }
    }
}
