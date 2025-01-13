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
    property color primaryTextCustomColor: Theme.palette.directColor1
    property string secondaryText
    property string icon
    property string badge
    property alias asset: listItem.asset
    property alias components: listItem.components
    property int listItemHeight: 76
    property bool highlighted

    StatusBaseText {
        text: root.caption
        font.pixelSize: Theme.additionalTextSize
    }
    StatusListItem {
        id: listItem
        Layout.fillWidth: true
        Layout.preferredHeight: root.listItemHeight
        title: root.primaryText
        statusListItemTitle.font.pixelSize: Theme.additionalTextSize
        statusListItemTitle.elide: Text.ElideMiddle
        statusListItemTitle.customColor: root.primaryTextCustomColor
        subTitle: root.secondaryText
        statusListItemSubTitle.font.pixelSize: Theme.additionalTextSize
        asset.name: root.icon
        asset.isImage: true
        asset.bgWidth: 40
        asset.bgHeight: 40
        border.width: 1
        border.color: Theme.palette.baseColor2
        highlighted: root.highlighted

        sensor.enabled: false

        statusListItemIcon.bridgeBadge.width: 16
        statusListItemIcon.bridgeBadge.height: 16
        statusListItemIcon.bridgeBadge.border.width: 1
        statusListItemIcon.bridgeBadge.image.source: root.badge
        statusListItemIcon.bridgeBadge.visible: !!root.badge
    }
}
