import QtQuick 2.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

StatusListItem {
    statusListItemTitle.customColor: Theme.palette.baseColor1
    statusListItemTitle.font.pixelSize: 13
    statusListItemTitle.lineHeightMode: Text.FixedHeight
    statusListItemTitle.lineHeight: 18
    statusListItemSubTitle.customColor: Theme.palette.directColor1
    statusListItemSubTitle.textFormat: Qt.RichText
    statusListItemSubTitle.wrapMode: Qt.TextWrapAnywhere
    statusListItemSubTitle.lineHeightMode: Text.FixedHeight
    statusListItemSubTitle.lineHeight: 22
    color: Theme.palette.transparent
}
