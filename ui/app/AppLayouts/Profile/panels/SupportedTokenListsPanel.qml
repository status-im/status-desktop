import QtQuick
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import QtModelsToolkit

import shared.controls
import utils

import AppLayouts.Profile.popups

StatusListView {
    id: root

    required property var tokenListsModel // Expected roles: id, name, timestamp, source, logoUri, version, tokens
    required property var allNetworks

    implicitHeight: contentHeight
    model: root.tokenListsModel
    spacing: Theme.halfPadding

    delegate: StatusListItem {
        height: ProfileUtils.defaultDelegateHeight
        width: ListView.view.width
        title: model.name
        forceDefaultCursor: true
        subTitle: qsTr("%n token(s) · Last updated %1", "", model.tokens.count).arg(LocaleUtils.getTimeDifference(new Date(model.timestamp * 1000), new Date()))
        statusListItemSubTitle.font.pixelSize: Theme.additionalTextSize
        asset.name: model.logoUri
        asset.isImage: true
        border.width: 1
        border.color: Theme.palette.baseColor5
        highlighted: viewButton.hovered
        components: [
            StatusFlatButton {
                id: viewButton

                text: qsTr("View")
                onClicked: popup.open()
            }
        ]

        Loader {
            id: popup

            active: false

            function open() {
                popup.active = true
            }

            function close() {
                popup.active = false
            }

            onLoaded: {
                popup.item.open()
            }

            sourceComponent: TokenListPopup {

                sourceImage: model.logoUri
                sourceUrl: model.source
                sourceVersion: model.version
                updatedAt: model.timestamp

                title: model.name

                tokensListModel: LeftJoinModel {
                    leftModel: model.tokens
                    rightModel: root.allNetworks

                    joinRole: "chainId"
                }

                onLinkClicked: (link) => Global.requestOpenLink(link)
            }
        }
    }
}
