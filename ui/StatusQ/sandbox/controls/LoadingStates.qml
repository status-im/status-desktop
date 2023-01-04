import QtQuick 2.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Column {
    spacing: 10

    StatusCheckBox {
        id: loadingButton
        text: checked ? "loaded": "loading"
        checkState: Qt.Unchecked
    }

    StatusTextWithLoadingState {
        font.pixelSize: 15
        text: "Text is big"
        loading: loadingButton.checked
        width: 100
    }

    StatusTextWithLoadingState {
        font.pixelSize: 22
        text: "Text is big"
        loading: loadingButton.checked
        width: 200
    }

    StatusListItem {
        title: "Nokia 3310"
        subTitle: "Incoming device"
        asset.width: 40
        asset.height: 40
        asset.emoji: "😁"
        asset.color: "hotpink"
        asset.letterSize: 14
        asset.isLetterIdenticon: true
        statusListItemSubTitle.loading: loadingButton.checked
    }

    StatusListItem {
        title: "Nokia 3310"
        subTitle: "Incoming device"
        asset.width: 40
        asset.height: 40
        asset.emoji: "😁"
        asset.color: "hotpink"
        asset.letterSize: 14
        asset.isLetterIdenticon: true
        statusListItemSubTitle.loading: loadingButton.checked
        statusListItemIcon.loading: loadingButton.checked
    }

    StatusListItem {
        title: "Nokia 3310"
        subTitle: "Incoming device"
        asset.width: 40
        asset.height: 40
        asset.emoji: "😁"
        asset.color: "hotpink"
        asset.letterSize: 14
        asset.isLetterIdenticon: true
        statusListItemTitle.loading: loadingButton.checked
        statusListItemSubTitle.loading: loadingButton.checked
        statusListItemIcon.loading: loadingButton.checked
    }

}
