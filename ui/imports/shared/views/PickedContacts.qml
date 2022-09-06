import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.status 1.0
import shared.stores 1.0
// TODO move Contact into shared to get rid of that import
import AppLayouts.Chat.controls 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

    property var contactsStore

    property var pubKeys: ([])

    readonly property alias count: contactGridView.count

    signal contactClicked(var contact)

    function matchesAlias(name, filter) {
        let parts = name.split(" ")
        return parts.some(p => p.startsWith(filter))
    }

    implicitWidth: contactGridView.implicitWidth + contactGridView.margins
    implicitHeight: visible ? contactGridView.contentHeight : 0

    StatusGridView {
        id: contactGridView
        anchors.fill: parent
        rightMargin: 0
        cellWidth: parent.width / 2
        cellHeight: 2 * Style.current.xlPadding + Style.current.halfPadding

        model: SortFilterProxyModel {
            sourceModel: root.contactsStore.myContactsModel
            filters: [
                ExpressionFilter { expression: root.pubKeys.indexOf(model.pubKey) > -1 }
            ]
        }

        delegate: StatusMemberListItem {
            width: contactGridView.cellWidth
            pubKey: Utils.getCompressedPk(model.pubKey)
            isContact: model.isContact
            status: model.onlineStatus
            userName: model.displayName
            asset.name: model.icon
            asset.isImage: true
            asset.width: 40
            asset.height: 40
            color: "transparent"
            asset.color: Utils.colorForColorId(model.colorId)
            ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.pubKey)
            statusListItemIcon.badge.border.color: Theme.palette.baseColor4
            statusListItemIcon.badge.implicitHeight: 14 // 10 px + 2 px * 2 borders
            statusListItemIcon.badge.implicitWidth: 14 // 10 px + 2 px * 2 borders
        }
    }
}
 
