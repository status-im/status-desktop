import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1

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

        model: SortFilterProxyModel {
            sourceModel: root.contactsStore.myContactsModel
            filters: [
                ExpressionFilter { expression: root.pubKeys.indexOf(model.pubKey) > -1 }
            ]
        }
        delegate: Contact {
            width: contactGridView.cellWidth
            showCheckbox: false
            pubKey: model.pubKey
            isContact: model.isContact
            isUser: false
            name: model.displayName
            image: model.icon
        }
    }
}
 