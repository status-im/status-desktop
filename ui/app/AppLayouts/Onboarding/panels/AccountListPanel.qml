import QtQuick 2.13
import QtQuick.Controls 2.13

import "../controls"

import utils 1.0

ListView {
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
        isSelected: function (index, keyUid) {
            return accountsView.isSelected(index, keyUid)
        }
        onAccountSelect: function (index) {
            accountsView.onAccountSelect(index)
        }
    }
}
