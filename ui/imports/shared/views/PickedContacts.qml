import QtQuick
import QtQuick.Controls

import StatusQ
import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme

import utils

import SortFilterProxyModel

Item {
    id: root

    property var contactsModel
    property var pubKeys: ([])

    readonly property alias count: contactGridView.count

    StatusGridView {
        id: contactGridView
        anchors.fill: parent
        rightMargin: 0
        cellWidth: parent.width / 2
        cellHeight: 2 * Theme.xlPadding + Theme.halfPadding

        model: SortFilterProxyModel {
            sourceModel: root.contactsModel
            filters: FastExpressionFilter {
                expression: root.pubKeys.indexOf(model.pubKey) > -1
                expectedRoles: ["pubKey"]
            }
        }

        delegate: StatusMemberListItem {
            objectName: "statusMemberListItem-%1".arg(model.compressedPubKey)
            width: contactGridView.cellWidth
            pubKey: model.isEnsVerified ? "" : model.compressedPubKey
            isContact: model.isContact
            status: model.onlineStatus
            nickName: model.localNickname
            userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
            icon.name: model.icon
            icon.width: 40
            icon.height: 40
            color: "transparent"
            icon.color: Utils.colorForColorId(model.colorId)
            colorHash: model.colorHash

            hoverEnabled: false
        }
    }
}
