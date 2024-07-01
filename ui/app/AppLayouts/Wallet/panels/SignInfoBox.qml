import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

ColumnLayout {
    id: root

    property string caption
    property string primaryText
    property string secondaryText
    property string icon
    property string badge
    property alias asset: listItem.asset
    property alias components: listItem.components

    StatusBaseText {
        text: root.caption
        font.pixelSize: Style.current.additionalTextSize
    }
    StatusListItem {
        id: listItem
        Layout.fillWidth: true
        Layout.preferredHeight: 76
        title: root.primaryText
        statusListItemTitle.font.pixelSize: Style.current.additionalTextSize
        statusListItemTitle.elide: Text.ElideMiddle
        subTitle: root.secondaryText
        statusListItemSubTitle.font.pixelSize: Style.current.additionalTextSize
        asset.name: root.icon
        asset.isImage: true
        border.width: 1
        border.color: Theme.palette.baseColor2

        sensor.enabled: false

        statusListItemIcon.bridgeBadge.width: 16
        statusListItemIcon.bridgeBadge.height: 16
        statusListItemIcon.bridgeBadge.border.width: 1
        statusListItemIcon.bridgeBadge.image.source: root.badge
        statusListItemIcon.bridgeBadge.visible: !!root.badge
    }
}
