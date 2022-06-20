import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.status 1.0
import shared.stores 1.0
// TODO move Contact into shared to get rid of that import
import AppLayouts.Chat.controls 1.0

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    height: visible ? Math.min(contactListView.contentHeight, (expanded ? 320 : 192)) : 0

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


    ScrollView {
        anchors.fill: parent

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: contactListView.contentHeight > contactListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            anchors.fill: parent
            spacing: 0
            clip: true
            id: contactListView
            model: root.contactsStore.myContactsModel
            delegate: Contact {
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
                    !root.community.hasMember(model.pubKey))
                }
                onContactClicked: function () {
                    root.contactClicked(model)
                }
            }
        }
    }
}


