import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusListItem {
    id: root

    required property string name
    required property string description
    required property string logoUrl
    required property string fees
    required property bool urlsNeedParameters

    property bool isUrlLoading: false

    title: root.name
    subTitle: root.description
    asset.name: root.logoUrl
    asset.isImage: true
    statusListItemSubTitle.maximumLineCount: 1
    statusListItemComponentsSlot.spacing: 8
    components: [
        StatusTextWithLoadingState {
            objectName: "feesText"
            text: root.loading ? Constants.dummyText: root.fees
            customColor: Theme.palette.baseColor1
            lineHeight: 24
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
            loading: root.loading
        },
        StatusIcon {
            icon: root.urlsNeedParameters ? "chevron-down": "tiny/external"
            rotation: root.urlsNeedParameters ? 270: 0
            color: sensor.containsMouse ? Theme.palette.directColor1: Theme.palette.baseColor1
            visible: !root.loading && !root.isUrlLoading
        },
        StatusLoadingIndicator {
            objectName: "loadingIndicator"
            visible: root.isUrlLoading
        }
    ]
}
