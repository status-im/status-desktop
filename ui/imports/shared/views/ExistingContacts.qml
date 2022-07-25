import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1

import utils 1.0
import shared.status 1.0
import shared.stores 1.0
// TODO move Contact into shared to get rid of that import
import AppLayouts.Chat.controls 1.0

Item {
    id: root

    property var contactsStore
    property var community

    property string filterText: ""
    property bool expanded: true
    property bool showCheckbox: false
    property bool hideCommunityMembers: false
    property var pubKeys: ([])

    signal contactClicked(var contact)

    function matchesAlias(name, filter) {
        let parts = name.split(" ")
        return parts.some(p => p.startsWith(filter))
    }

    implicitWidth: contactListView.implicitWidth
    implicitHeight: visible ? Math.min(contactListView.contentHeight, (expanded ? 320 : 192)) : 0

    StatusListView {
        id: contactListView
        anchors.fill: parent
        spacing: 0

        model: root.contactsStore.myContactsModel
        delegate: Contact {
            width: contactListView.availableWidth
            showCheckbox: root.showCheckbox
            isChecked: root.pubKeys.indexOf(model.pubKey) > -1
            pubKey: model.pubKey
            isContact: model.isContact
            isUser: false
            name: model.displayName
            image: model.icon
            isVisible: {
                return model.isContact && !model.isBlocked && (root.filterText === "" ||
                    root.matchesAlias(model.alias.toLowerCase(), root.filterText.toLowerCase()) ||
                    model.displayName.toLowerCase().includes(root.filterText.toLowerCase()) ||
                    model.ensName.toLowerCase().includes(root.filterText.toLowerCase()) ||
                    model.localNickname.toLowerCase().includes(root.filterText.toLowerCase()) ||
                    model.pubKey.toLowerCase().includes(root.filterText.toLowerCase())) &&
                    (!root.hideCommunityMembers ||
                    !root.community.hasMember(model.pubKey));
            }
            onContactClicked: function () {
                root.contactClicked(model);
            }
        }
    }
}


