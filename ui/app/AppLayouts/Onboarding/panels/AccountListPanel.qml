import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1

import utils 1.0

import "../controls"

StatusListView {
    id: accountsView

    property var isSelected: function () {}
    property var onAccountSelect: function () {}

    anchors.fill: parent
    focus: true
    spacing: Style.current.halfPadding

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
