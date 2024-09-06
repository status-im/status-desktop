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
import AppLayouts.Profile.stores 1.0 as ProfileStores

import SortFilterProxyModel 0.2

Item {
    id: root

    property ProfileStores.ContactsStore contactsStore

    property var pubKeys: ([])

    readonly property alias count: contactGridView.count

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
            pubKey: model.isEnsVerified ? "" : Utils.getCompressedPk(model.pubKey)
            isContact: model.isContact
            status: model.onlineStatus
            nickName: model.localNickname
            userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
            icon.name: model.icon
            icon.width: 40
            icon.height: 40
            color: "transparent"
            icon.color: Utils.colorForColorId(model.colorId)
            ringSettings.ringSpecModel: model.colorHash
            badge.border.color: Theme.palette.baseColor4
            badge.implicitHeight: 14 // 10 px + 2 px * 2 borders
            badge.implicitWidth: 14 // 10 px + 2 px * 2 borders

            hoverEnabled: false
        }
    }
}
