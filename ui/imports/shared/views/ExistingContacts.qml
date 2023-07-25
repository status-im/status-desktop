import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
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

    property var rootStore
    property var contactsStore
    property string communityId

    property string filterText: ""
    property bool expanded: true
    property bool showCheckbox: false
    property bool hideCommunityMembers: false
    property var pubKeys: ([])

    readonly property alias count: contactListView.count

    signal contactClicked(var contact)

    function matchesAlias(name, filter) {
        let parts = name.split(" ")
        return parts.some(p => p.startsWith(filter))
    }

    implicitWidth: contactListView.implicitWidth + contactListView.margins
    implicitHeight: visible ? Math.min(contactListView.contentHeight, (expanded ? 320 : 192)) : 0

    StatusListView {
        id: contactListView
        objectName: "ExistingContacts_ListView"
        anchors.fill: parent
        rightMargin: 0
        leftMargin: 0
        spacing: Style.current.padding

        model: SortFilterProxyModel {
            sourceModel: root.contactsStore.myContactsModel
            filters: [
                ExpressionFilter {
                    expression: {
                        root.filterText
                        root.hideCommunityMembers
                        root.communityId

                        if (!model.isContact || model.isBlocked)
                            return false

                        const filter = root.filterText.toLowerCase()
                        const filterAccepted = root.filterText === ""
                                             || root.matchesAlias(model.alias.toLowerCase(), filter)
                                             || model.displayName.toLowerCase().includes(filter)
                                             || model.ensName.toLowerCase().includes(filter)
                                             || model.localNickname.toLowerCase().includes(filter)
                                             || model.pubKey.toLowerCase().includes(filter)

                        if (!filterAccepted)
                            return false

                        return !root.hideCommunityMembers ||
                               !root.rootStore.communityHasMember(root.communityId, model.pubKey)
                    }
                }
            ]
        }

        delegate: StatusMemberListItem {
            width: contactListView.availableWidth
            pubKey: model.isEnsVerified ? "" : Utils.getCompressedPk(model.pubKey)
            isContact: model.isContact
            status: model.onlineStatus
            height: visible ? implicitHeight : 0
            color: sensor.containsMouse ? Theme.palette.baseColor2 : "transparent"
            nickName: model.localNickname
            userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
            asset.name: model.icon
            asset.isImage: (asset.name !== "")
            asset.isLetterIdenticon: (asset.name === "")
            asset.width: 40
            asset.height: 40
            asset.color: Utils.colorForColorId(model.colorId)
            ringSettings.ringSpecModel: model.colorHash
            statusListItemIcon.badge.border.color: Theme.palette.baseColor4
            statusListItemIcon.badge.implicitHeight: 14 // 10 px + 2 px * 2 borders
            statusListItemIcon.badge.implicitWidth: 14 // 10 px + 2 px * 2 borders

            onClicked: {
                root.contactClicked(model);
            }

            StatusCheckBox  {
                id: contactCheckbox
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                checked: root.pubKeys.indexOf(model.pubKey) > -1
                onClicked: {
                    root.contactClicked(model);
                }
            }
        }
    }
}
