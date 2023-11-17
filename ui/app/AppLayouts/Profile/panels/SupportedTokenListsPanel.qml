import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import SortFilterProxyModel 0.2
import shared.controls 1.0
import utils 1.0

import AppLayouts.Profile.popups 1.0

StatusListView {
    id: root

    required property var sourcesOfTokensModel // Expected roles: key, name, updatedAt, source, version, tokensCount, image
    required property var tokensListModel // Expected roles: name, symbol, image, chainName, explorerUrl

    signal itemClicked(string key)

    implicitHeight: contentHeight
    model: root.sourcesOfTokensModel
    spacing: 8
    delegate: StatusListItem {
        height: 76
        width: ListView.view.width
        title: model.name
        subTitle: qsTr("%n token(s) · Last updated %1 @%2",
                       "",
                       model.tokensCount).arg(LocaleUtils.formatDate(model.updatedAt * 1000)).arg(LocaleUtils.formatTime(model.updatedAt, Locale.ShortFormat))
        asset.name: model.image
        asset.isImage: true
        border.width: 1
        border.color: Theme.palette.baseColor5
        components: [
            StatusButton {
                text: qsTr("View")

                onClicked: keyFilter.value = model.key
            }
        ]
    }

    footer: Item {
        width: parent.width
        height: root.count > 0 ? shapeRect.implicitHeight + 40 : shapeRect.implicitHeight

        ShapeRectangle {
            id: shapeRect

            anchors.bottom: parent.bottom
            width: parent.width - 4 // The rectangular path is rendered outside

            icon: "add"
            text: qsTr("Add Token List (coming soon)")
        }
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

            readonly property TokenListPopup popup: TokenListPopup {
                parent: root

                sourceName: delegate.name
                sourceImage: delegate.image
                sourceUrl: delegate.source
                sourceUpdatedAt: delegate.updatedAt
                sourceVersion: delegate.version
                tokensCount: delegate.tokensCount

                tokensListModel: SortFilterProxyModel {
                    sourceModel: root.tokensListModel

                    // Filter by source
                    filters: RegExpFilter {
                        roleName: "sources"
                        pattern: "\;" + keyFilter.value + "\;"
                    }
                }

                onLinkClicked: Global.openLink(link)
                onClosed: keyFilter.value = ""
                Component.onCompleted: open()
            }
        }
    }
}
