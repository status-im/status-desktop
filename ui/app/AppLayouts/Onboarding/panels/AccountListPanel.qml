import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1

import utils 1.0

import "../controls"

StatusListView {
    id: accountsView

    property var isSelected: function () {}
    property var onAccountSelect: function () {}

    anchors.fill: parent
    focus: true
    spacing: Theme.halfPadding

    delegate: AccountViewDelegate {
        username: model.username
        image: model.thumbnailImage
        keyUid: model.keyUid
        address: model.address || ''
        colorHash: model.colorHash
        colorId: model.colorId
        isSelected: function (index, keyUid) {
            return accountsView.isSelected(index, keyUid)
        }
        onAccountSelect: function (index) {
            accountsView.onAccountSelect(index)
        }
    }
}
