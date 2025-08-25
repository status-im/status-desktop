import QtQuick
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import SortFilterProxyModel
import shared.controls
import utils

import AppLayouts.Profile.popups

StatusListView {
    id: root

    required property var sourcesOfTokensModel // Expected roles: key, name, updatedAt, source, version, tokensCount, image
    required property var tokensListModel // Expected roles: name, symbol, image, chainName, explorerUrl

    signal itemClicked(string key)

    implicitHeight: contentHeight
    model: root.sourcesOfTokensModel
    spacing: Theme.halfPadding
    delegate: StatusListItem {
        height: ProfileUtils.defaultDelegateHeight
        width: ListView.view.width
        title: model.name
        forceDefaultCursor: true
        subTitle: qsTr("%n token(s) · Last updated %1", "", model.tokensCount).arg(LocaleUtils.getTimeDifference(new Date(model.updatedAt * 1000), new Date()))
        statusListItemSubTitle.font.pixelSize: Theme.additionalTextSize
        asset.name: model.image
        asset.isImage: true
        border.width: 1
        border.color: Theme.palette.baseColor5
        highlighted: viewButton.hovered
        components: [
            StatusFlatButton {
                id: viewButton

                text: qsTr("View")
                onClicked: keyFilter.value = model.key
            }
        ]
    }

    Instantiator {
        model: SortFilterProxyModel {
            sourceModel: sourcesOfTokensModel

            filters: ValueFilter {
                id: keyFilter

                roleName: "key"
                value : ""
            }
        }

        delegate: QtObject {
            id: delegate

            required property string name
            required property string image
            required property string source
            required property int updatedAt
            required property string version
            required property int tokensCount

            Component.onCompleted: popup.open()
        }
    }

    TokenListPopup {
        id: popup

        sourceImage: delegate.image
        sourceUrl: delegate.source
        sourceVersion: delegate.version
        updatedAt: delegate.updatedAt
        tokensCount: delegate.tokensCount

        title: delegate.name

        tokensListModel: SortFilterProxyModel {
            sourceModel: root.tokensListModel

            // Filter by source
            filters: RegExpFilter {
                roleName: "sources"
                pattern: "\;" + keyFilter.value + "\;"
            }
        }

        onLinkClicked: (link) => Global.openLink(link)
        onClosed: keyFilter.value = ""
    }
}
