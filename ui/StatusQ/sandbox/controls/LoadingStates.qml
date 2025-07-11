import QtQuick

import StatusQ.Controls
import StatusQ.Components

Column {
    spacing: 10

    StatusCheckBox {
        id: loadingButton
        text: checked ? "loaded": "loading"
        checkState: Qt.Unchecked
    }

    StatusTextWithLoadingState {
        font.pixelSize: Theme.primaryTextFontSize
        text: "Text is big"
        loading: loadingButton.checked
        width: 100
    }

    StatusTextWithLoadingState {
        font.pixelSize: Theme.fontSize22
        text: "Text is big"
        loading: loadingButton.checked
        width: 200
    }

    component DeviceListItem: StatusListItem {
        title: "Nokia 3310"
        subTitle: "Incoming device"
        asset.width: 40
        asset.height: 40
        asset.emoji: "😁"
        asset.color: "hotpink"
        asset.letterSize: 14
        asset.isLetterIdenticon: true
    }

    DeviceListItem {
        statusListItemSubTitle.loading: loadingButton.checked
    }

    DeviceListItem {
        statusListItemSubTitle.loading: loadingButton.checked
        statusListItemIcon.loading: loadingButton.checked
    }

    DeviceListItem {
        statusListItemTitle.loading: loadingButton.checked
        statusListItemSubTitle.loading: loadingButton.checked
        statusListItemIcon.loading: loadingButton.checked
    }
}
